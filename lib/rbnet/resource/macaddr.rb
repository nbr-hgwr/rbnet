# frozen_string_literal: true

module Rbnet
  class MacAddr
    def initialize(addr)
      @addr = addr
    end

    def to_s
      @addr.map { |v| v.to_s(16).rjust(2, '0') }.join(':')
    end
  end
end