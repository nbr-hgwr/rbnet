# frozen_string_literal: true

module Rbnet
  # デフォゲのデータを持つ構造体
  class DefaultGateway
    attr_reader :ip_daddr, :interface

    def initialize(ip_daddr, interface)
      @ip_daddr = ip_daddr
      @interface = interface
    end
  end
end
