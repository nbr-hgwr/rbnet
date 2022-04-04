# frozen_string_literal: true

require 'rbshark'

module Rbnet
  class Executor
    def initialize(frame, recv_interface)
      @frame = frame
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
        @packet_info.set_arp(arp_header)
        if @print
          @printer.print_arp(arp_header) if @view
          @printer.print_arp_short(@packet_info.packet_info) unless @view
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
