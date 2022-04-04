# frozen_string_literal: true

require 'rbshark'

module Rbnet
  class Executor
    def initialize(frame, ts, recv_interface)
      @frame = frame
      @ts = ts
      @recv_interface = recv_interface
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
        if $arp_table.key?(arp_header.ar_sip.to_s.to_sym)
          $arp_table.update_timestamp(ts)
        else
          $arp_table.push_mac_ip_to_entry(arp_header.ar_sip.to_s, arp_header.ar_sha.to_s, recv_interface, ts)
        end

        # ARP REQUESTの場合、自身のMACアドレスとIPアドレスをパケットにセットして返信
        if arp_header.ar_op == 1
          # To Do
        end
      when 'IP'
         # IPパケットの解析
        ip_header = Rbshark::IPV4Analyzer.new(@frame, ether_header.return_byte)

        # IPヘッダのチェックサムをValidation

        # IPヘッダのTTLを1減らす
        # 0になった場合ICMP Time Exceededパケットを送り返す

        # IPヘッダのチェックサムを再計算

        # ARPテーブルに宛先IPアドレスのエントリがあるかチェック
        # 無い場合: パケットを送信待ちデータに格納してARP Requestを送信
        # ある場合: パケット送信処理

        # MACアドレスの書き換え

        # 送出側のインターフェースからパケットを送出


        exec_ip(ip_header)
      end
    end
  end
end
