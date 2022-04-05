# frozen_string_literal: true

require 'rbshark'

module Rbnet
  class Executor
    def initialize(frame, ts, recv_interface, interfaces)
      @frame = frame
      @ts = ts
      @recv_interface = recv_interface
      @interfaces = interfaces
    end

    def exec_ether
      ether_header = Rbshark::EthernetAnalyzer.new(@frame)

      # 宛先MACアドレスが受信したインターフェースのMACアドレスと一致しているかチェック
      # 一致していない (=ブロードキャスト)場合は転送しない
      return unless ether_header.ether_dhost.to_s == @recv_interface.hw_addr.to_s

      case ether_header.check_protocol_type
      when 'ARP'
        arp_header = Rbshark::ARPAnalyzer.new(@frame, ether_header.return_byte)

        # target IPが受信したインターフェースのIPアドレスと一致するかをチェック
        return unless arp_header.ar_tip.to_s == @recv_interface.in_addr[:ip_addr]

        # arp tableに登録があるかをチェック
        if $arp_table.entry.key?(arp_header.ar_sip.to_s.to_sym)
          $arp_table.update_timestamp(arp_header.ar_sip.to_s, @ts)
          puts "[Update TimeStamp] #{arp_header.ar_sip.to_s} -> #{arp_header.ar_sha.to_s} #{@ts}"
        else
          $arp_table.push_mac_ip_to_entry(arp_header.ar_sip.to_s, arp_header.ar_sha.to_s, @recv_interface, @ts)
          puts "[Push ARP Entry]   #{arp_header.ar_sip.to_s} -> #{arp_header.ar_sha.to_s} #{@ts}"
        end

        # ARP REQUESTの場合、自身のMACアドレスとIPアドレスをパケットにセットして返信
        if arp_header.ar_op == 1
          # To Do
        end
      when 'IP'
         # IPパケットの解析
        ip_header = Rbshark::IPV4Analyzer.new(@frame, ether_header.return_byte)

        # IPヘッダのチェックサムをValidation
        retrun if ip_header.vali_sum == false

        # IPヘッダのTTLを1減らす
        # 0になった場合ICMP Time Exceededパケットを送り返す
        ttl = ip_header.ip_ttl - 1
        send_icmp_time_exceeded() if ttl == 0

        # IPヘッダのチェックサムを再計算
        # ttlとcksumを更新したIPヘッダのframeを取得
        ip_frame = calculate_cksum(ip_header, ttl)

        # ARPテーブルに宛先IPアドレスのエントリがあるかチェック
        # ある場合: パケット送信処理
        # 無い場合: パケットを送信待ちデータに格納してARP Requestを送信
        if $arp_table.entry.key?(ip_header.ip_dst.to_s.to_sym)
          # ある場合
          hw_dhost  = $arp_table.entry[ip_header.ip_dst.to_s.to_sym][:hw_addr].to_s
          sock = $arp_table.entry[ip_header.ip_dst.to_s.to_sym][:sock]
        else
          # 無い場合
          # arp request発出
          retrun
        end

        # 送出するインターフェースを判別する
        send_interface = nil
        @interfaces.each do |interface|
          if interface.in_addr[:subnet].include?(ip_header.ip_dst.to_s)
            send_interface = interface
          else
            # To Do
          end
        end

        # MACアドレスの書き換え
        if send_interface.nil?
          hw_shost = send_interface.hw_addr
          ether_frame = remake_ether_header(ether_header, hw_dhost, hw_shost)
        end

        # 送出側のインターフェースからパケットを送出

      end
    end

    def send_icmp_time_exceeded()
      # To Do
      icmp_time_exceeded = Rbnet::ICMP_TIME_EXCEEDED()
    end

    def calculate_cksum(ip_header, ttl)
      # IPヘッダ部分をframeから抽出
      ip_frame = @frame[ip_header.start_byte..ip_header.return_byte]
      # ttl書き換え
      ip_frame[8] = ttl.chr

      ip_header_byte = ip_header.return_byte - ip_header.start_byte
      byte = 0
      sum  = 0
      ip_frame[10..11] = sum.chr + sum.chr

      # 16bitずつ足し合わせる
      for i in 1..ip_header_byte/2
        sum += (ip_frame[byte].ord << 8) + @frame[byte + 1].ord
        byte += 2
      end
      sum = sum.to_s(16)
      sum = sum[0].to_i(16) + sum[1..4].to_i(16)

      # 補数を取る
      complement = sprintf("%#x", ~sum)
      # .chrが8bitまでしか対応していないため2桁ずつ分ける (cksumは16bit)
      cksum = complement.slice(-4,2).to_i(16).chr + complement.slice(-2,2).to_i(16).chr
      # cksumのフィールドを再計算したものに置き換える
      ip_frame[10..11] = cksum
      ip_frame
    end

    def remake_ether_header(ether_header, hw_dhost, hw_shost)
    end
  end
end
