# frozen_string_literal: true

require 'rbshark'

module Rbnet
  class Executor
    def initialize(frame, timestamp, recv_interface, interfaces, default_gateway)
      @frame = frame
      @timestamp = timestamp
      @recv_interface = recv_interface
      @interfaces = interfaces
      @default_gateway = default_gateway
    end

    def exec_ether
      ether_header = Rbshark::EthernetAnalyzer.new(@frame)

      # 宛先MACアドレスが受信したインターフェースのMACアドレスと一致しているかチェック
      # 一致していない (=ブロードキャスト)場合は転送しない
      return unless ether_header.ether_dhost.to_s == @recv_interface.hw_addr.to_s

      case ether_header.check_protocol_type
      when 'ARP'
        arp_header = Rbshark::ARPAnalyzer.new(@frame, ether_header.return_byte)
        exec_arp(arp_header)
      when 'IP'
        # IPパケットの解析
        ip_header = Rbshark::IPV4Analyzer.new(@frame, ether_header.return_byte)
        exec_ip(ip_header, ether_header)
      end
    end

    def exec_arp(arp_header)
      # target IPが受信したインターフェースのIPアドレスと一致するかをチェック
      return unless arp_header.ar_tip.to_s == @recv_interface.in_addr[:ip_addr]

      # arp tableに登録があるかをチェック
      if $arp_table.entry.key?(arp_header.ar_sip.to_s.to_sym)
        $arp_table.update_timestamp(arp_header.ar_sip.to_s, @timestamp)
        puts "[Update TimeStamp] #{arp_header.ar_sip} -> #{arp_header.ar_sha} #{@timestamp}"
      else
        $arp_table.push_mac_ip_to_entry(arp_header.ar_sip.to_s, arp_header.ar_sha.to_s, @recv_interface, @timestamp)
        puts "[Push ARP Entry]   #{arp_header.ar_sip} -> #{arp_header.ar_sha} #{@timestamp}"
      end

      # ARP REQUESTの場合、自身のMACアドレスとIPアドレスをパケットにセットして返信
      if arp_header.ar_op == 1
        # To Do
      end
    end

    def exec_ip(ip_header, ether_header)
      # IPヘッダのチェックサムをValidation
      retrun if ip_header.vali_sum == false

      # IPヘッダのTTLを1減らす
      # 0になった場合ICMP Time Exceededパケットを送り返す
      ttl = ip_header.ip_ttl - 1
      send_icmp_time_exceeded if ttl.zero?

      # IPヘッダのチェックサムを再計算
      # ttlとcksumを更新したIPヘッダのframeを取得
      ip_header_tmp = calculate_cksum(ip_header, ttl)

      # 送出するインターフェースを判別する
      send_interface = nil
      @interfaces.each do |interface|
        next if interface == @recv_interface
        # 宛先IPがインターフェースのsubnet内のIPアドレスか判定
        if interface.in_addr[:subnet].include?(ip_header.ip_dst.to_s)
          send_interface = interface
        end
      end
      send_interface = @default_gateway.interface if send_interface.nil?

      # ARPテーブルに宛先IPアドレスのエントリがあるかチェック
      # ある場合: パケット送信処理
      # 無い場合: パケットを送信待ちデータに格納してARP Requestを送信
      if $arp_table.entry.key?(ip_header.ip_dst.to_s.to_sym) || $arp_table.entry.key?(@default_gateway.ip_daddr)
        # ある場合
        hw_dhost = $arp_table.entry[ip_header.ip_dst.to_s.to_sym][:hw_addr].to_s
      else
        # 無い場合
        # send_interface != nilの時arp request発出
        return
      end

      # MACアドレスの書き換え
      # send_interface = nilの場合、デフォゲに発出するインターフェースからsource MACを取得
      hw_shost = send_interface.hw_addr
      ether_frame = remake_ether_header(ether_header, hw_shost, hw_dhost)

      # 元パケットのethernetヘッダとIPヘッダを書き換える
      @frame[ether_header.start_byte..ether_header.return_byte] = ether_frame
      @frame[ip_header.start_byte..ip_header.return_byte] = ip_header_tmp

      # 送出側のインターフェースからパケットを送出
      send_interface.sock.send(@frame, 0)
    end

    def send_icmp_time_exceeded
      # To Do
      # icmp_time_exceeded = Rbnet::ICMP_TIME_EXCEEDED()
    end

    def calculate_cksum(ip_header, ttl)
      # IPヘッダ部分をframeから抽出
      ip_header_tmp = @frame[ip_header.start_byte..ip_header.return_byte]
      # ttl書き換え
      ip_header_tmp[8] = ttl.chr

      ip_header_byte = ip_header.return_byte - ip_header.start_byte
      byte = 0
      sum  = 0
      ip_header_tmp[10..11] = sum.chr + sum.chr

      # 16bitずつ足し合わせる
      (1..ip_header_byte / 2).each do |_index|
        sum  += (ip_header_tmp[byte].ord << 8) + ip_header_tmp[byte + 1].ord
        byte += 2
      end
      sum = sum.to_s(16)
      sum = sum[0].to_i(16) + sum[1..4].to_i(16)

      # 補数を取る
      complement = format('%#x', ~sum)
      # .chrが8bitまでしか対応していないため2桁ずつ分ける (cksumは16bit)
      cksum = complement.slice(-4, 2).to_i(16).chr + complement.slice(-2, 2).to_i(16).chr
      # cksumのフィールドを再計算したものに置き換える
      ip_header_tmp[10..11] = cksum
      ip_header_tmp
    end

    def remake_ether_header(ether_header, hw_dhost, hw_shost)
      ether_frame = @frame[ether_header.start_byte..ether_header.return_byte]

      hw_shost.to_s.split(':').each_with_index do |oct, index|
        ether_frame[index]  = oct.to_i(16).chr
      end

      hw_dhost.to_s.split(':').each_with_index do |oct, index|
        ether_frame[index+6]  = oct.to_i(16).chr
      end
      ether_frame
    end
  end
end
