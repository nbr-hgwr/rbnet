# frozen_string_literal: true

require 'ipaddress'
require 'ipaddr'

module Rbnet
  # ネットワークインターフェースの情報を持つ構造体
  class Interface
    attr_reader :sock
    attr_reader :hw_addr
    attr_reader :in_addr

    def initialize(sock, if_name)
      @sock = sock
      @in_addr = {
        ip_addr: nil,
        netmask: nil,
        subnet:  nil
      }
      get_addr_used_if(if_name)
      get_netmask_used_if(if_name)
      @in_addr[:subnet] = IPAddr.new("#{@in_addr[:ip_addr]}/#{@in_addr[:netmask]}")
    end

    def get_addr_used_if(if_name)
      Socket.getifaddrs.select{|a| a.name == if_name}.map(&:addr).each do |addr|
        case addr.pfamily
        when 2
          # IPv4
          @in_addr[:ip_addr] = addr.ip_address
        when 10
          # IPv6
          # リンクローカルとの区別もあるで要修正
          # リンクローカルだと addr.ip_address = "fe80::42:c0ff:fea8:3%eth0"
          ip6_addr = addr.ip_address
        when 17
          # MACアドレス
          @hw_addr = Rbnet::MacAddr.new addr.to_s[-6..-1][0..6].split('').map { |c| c.ord }
          #addr.to_s[-6..-1].unpack('H*')[0]
        end
      end
    end

    def get_netmask_used_if(if_name)
      Socket.getifaddrs.select{|a| a.name == if_name}.map(&:netmask).each do |mask|
        next if mask == nil
        case mask.pfamily
        when 2
          # IPv4
          @in_addr[:netmask] = mask.ip_address
        end
      end
    end
  end
end
