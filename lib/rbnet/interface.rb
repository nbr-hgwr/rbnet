# frozen_string_literal: true

module Rbnet
  class Interface
    def get_interface(socket, interface)
      # キャプチャを行うネットワークデバイスを取得して返す
      ifreq = []
      ifreq.push(interface)
      ifreq = ifreq.dup.pack('a' + Rbnet::IFREQ_SIZE.to_s)
      socket.ioctl(Rbnet::SIOCGIFINDEX, ifreq)
      if_num = ifreq[Socket::IFNAMSIZ, Rbnet::IFINDEX_SIZE]

      if_num
    end
  end
end
