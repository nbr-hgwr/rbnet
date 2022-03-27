# frozen_string_literal: true

module Rbnet
  class Executor
    def initialize(frame, count, print)
      @frame = frame
      @count = count

      @packet_info = Rbnet::PacketInfo.new(count)
      exec()
    end

    def exec
      ether_header = Rbnet::EthernetAnalyzer.new(@frame)
      @packet_info.set_ether(ether_header)
      print_ethernet(ether_header) if @print
    end

    def print_ethernet(ether_header)
      puts "Frame Num: #{@count}"
      puts 'Ethernet Header-----------------'
      puts "  dst: #{ether_header.ether_dhost}"
      puts "  src: #{ether_header.ether_shost}"
      puts "  type: #{ether_header.ether_type} (#{ether_header.check_protocol_type})"
    end

  end
end