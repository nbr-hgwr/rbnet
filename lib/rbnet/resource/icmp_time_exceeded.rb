# frozen_string_literal: true

require 'socket'

module Rbnet
  ICMP_TIME_EXCEEDED   = 11
  ICMP_TIMXEED_INTRANS = 0
  ETHERTYPE_IP         = 0x0800

  class ICMPTimeExceeded
    attr_reader :packet

    def initialize(ether_saddr = nil, ether_daddr = nil, ip_saddr = nil, ip_daddr = nil)
      @packet = {
        ether_saddr: {
          value: ether_saddr,
          bit: 48
        },
        ether_daddr: {
          value: ether_daddr,
          bit: 48
        },
        ether_type: {
          value: ETHERTYPE_IP,
          bit: 16
        },
        ip_version: {
          value: 4,
          bit: 4
        },
        # オプションは使わなため、IPヘッダは20Byteになる
        ip_hlen: {
          value: 20 / 4,
          bit: 4
        },
        ip_tos: {
          value: 0,
          bit: 8
        },
        ip_tot_len: {
          value:,
          bit: 16
        },
        ip_id: {
          value: 0,
          bit: 16
        },
        ip_flag_off: {
          value: 0,
          bit: 16
        },
        ip_ttl: {
          value: 64,
          bit: 8
        },
        ip_protocol: {
          value: Socket::IPPROTO_ICMP,
          bit: 8
        },
        ip_cksum: {
          value: 0,
          bit: 16
        },
        ip_saddr: {
          value: ip_saddr,
          bit: 32
        },
        ip_daddr: {
          value: ip_daddr,
          bit: 32
        },
        icmp_type: {
          value: ICMP_TIME_EXCEEDED,
          bit: 8
        },
        icmp_code: {
          value: ICMP_TIMXEED_INTRANS,
          bit: 8
        },
        icmp_cksum: {
          value: 0,
          bit: 16
        }
      }
    end
  end
end
