# frozen_string_literal: true

module Rbnet
  class Interface
    attr_reader :sock
    attr_reader :hw_addr
    attr_reader :in_addr

    def initialize(sock, if_name, hw_addr, ip_addr, subnet, netmask)
      @sock = sock
      get_addr_used_if(if_name)
      get_netmask_used_if(if_name)
      @in_addr = {
        ip_addr: @ip_addr,
        netmask: sock_if.netmask.ip_address
      }
    end

    def get_addr_used_if(if_name)
      Socket.getifaddrs.select{|a| a.name == if_name}.map(&:addr).each do |addr|
        case addr.pfamily
        when 2
          # IPv4
          @ip_addr = addr.ip_address
        when 10
          # IPv6
          # リンクローカルとの区別もあるで要修正
          # リンクローカルだと addr.ip_address = "fe80::42:c0ff:fea8:3%eth0"
          @ip6_addr = addr.ip_address
        when 17
          # MACアドレス
          @hw_addr = addr.to_s[-6..-1].unpack('H*')[0]
        end
      end
      sock_if
    end

    def get_netmask_used_if(if_name)
      Socket.getifaddrs.select{|a| a.name == if_name}.map(&:netmask).each do |mask|
        next if mask == nil
        case mask.pfamily
        when 2
          # IPv4
          @netmask = addr.ip_address
        end
      end
    end
  end
end
