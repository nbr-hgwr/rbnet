# frozen_string_literal: true

module Rbnet
  class Analyzer
    def uint8(size)
      binary = if size == 1
            @frame[@byte].ord
          else
            @frame[@byte...@byte + size].split('').map { |c| c.ord }
          end
      @byte += size
      binary
    end

    def uint16
      binary = (@frame[@byte].ord << 8) + @frame[@byte + 1].ord
      @byte += 2
      binary
    end

    def uint32
      binary = (@frame[@byte].ord << 24) + (@frame[@byte + 1].ord << 16) + (@frame[@byte + 2].ord << 8 ) + @frame[@byte + 3].ord
      @byte += 4
      binary
    end

    def return_byte
      @byte
    end
  end

  class EthernetAnalyzer < Analyzer
    attr_reader :ether_dhost
    attr_reader :ether_shost
    attr_reader :ether_type

    def initialize(frame, byte = 0)
      @frame = frame
      @byte = byte

      @ether_dhost = MacAddr.new uint8(6)
      @ether_shost = MacAddr.new uint8(6)
      @ether_type = uint16
    end

    def check_protocol_type
      case @ether_type
      when ETH_P_IP
        'IP'
      when ETH_P_IPV6
        'IPv6'
      when ETH_P_ARP
        'ARP'
      else
        'Other'
      end
    end
  end
end