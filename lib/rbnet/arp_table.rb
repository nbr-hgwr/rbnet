# frozen_string_literal: true

module Rbnet
  # ネットワークインターフェースの情報を持つ構造体
  class ARPTable
    attr_reader :entry
    def initialize()
      @entry = {}
    end

    def push_mac_ip_to_entry(ip_addr, hw_addr, interface, ts)
      @entry[ip_addr.to_sym] = {
        hw_addr: hw_addr,
        interface: interface,
        ts:      ts
      }
    end

    def update_timestamp(ip_addr, ts)
      @entry[ip_addr.to_sym][:ts] = ts
    end
  end
end
