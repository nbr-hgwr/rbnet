# frozen_string_literal: true

module Rbnet
  # ネットワークインターフェースの情報を持つ構造体
  class ARPTable
    attr_reader :entry

    def initialize
      @entry = {}
    end

    def push_mac_ip_to_entry(ip_addr, hw_addr, interface, timestamp)
      @entry[ip_addr.to_sym] = {
        hw_addr:,
        interface:,
        timestamp:
      }
    end

    def update_timestamp(ip_addr, timestamp)
      @entry[ip_addr.to_sym][:timestamp] = timestamp
    end
  end
end
