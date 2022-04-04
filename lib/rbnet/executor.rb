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
          $arp_table.push_mac_ip_to_entry(arp_header.ar_sip.to_s, arp_header.ar_sha.to_s, ts)
        end

        case arp_header.ar_op
        when 1
          # ARP REQUEST
        when 2
          # ARP REPLY
        else
          return
        end
      when 'IP'
        ip_header = Rbshark::IPV4Analyzer.new(@frame, ether_header.return_byte)
        @packet_info.set_ip(ip_header)

        if @print
          @printer.print_ip(ip_header) if @view
        end
        exec_ip(ip_header)
      when 'IPv6'
        ip6_header = IPV6Analyzer.new(@frame, ether_header.return_byte)
        @packet_info.set_ipv6(ip6_header)

        if @print
          @printer.print_ip6(ip6_header) if @view
        end
        exec_ip6(ip6_header)
      end
    end
  end
end
