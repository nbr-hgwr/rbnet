# frozen_string_literal: true

require 'socket'
require 'rbshark'

module Rbnet
  class Router
    def initialize(interfaces_name, options)
      @interfaces_name = interfaces_name
      @options = options
    end

    def start
      $arp_table = Rbnet::ARPTable.new
      interfaces = []
      default_gateway = nil
      (0..@interfaces_name.size - 1).each do |index|
        sock = Socket.open(Socket::AF_PACKET, Socket::SOCK_RAW, Rbnet::ETH_P_ALL)
        if_num = get_interface(sock, @interfaces_name[index])
        interfaces.push(Rbnet::Interface.new(sock, @interfaces_name[index]))
        sock.bind(sockaddr_ll(if_num))
        default_gateway = Rbnet::DefaultGateway.new('192.168.30.3', interfaces.last) if @interfaces_name[index] == 'eth3'
      end
      router(interfaces, default_gateway)
    end

    def get_interface(socket, interface)
      # キャプチャを行うネットワークデバイスを取得して返す
      ifreq = []
      ifreq.push(interface)
      # rubocop:disable Style/StringConcatenation
      ifreq = ifreq.dup.pack('a' + Rbnet::IFREQ_SIZE.to_s)
      # rubocop:enable Style/StringConcatenation
      socket.ioctl(Rbnet::SIOCGIFINDEX, ifreq)
      ifreq[Socket::IFNAMSIZ, Rbnet::IFINDEX_SIZE]
    end

    def sockaddr_ll(ifnum)
      sll = [Socket::AF_PACKET].pack('s')
      sll << [Rbnet::ETH_P_ALL].pack('s')
      sll << ifnum
      sll << ('\x00' * (Rbnet::SOCKADDR_LL_SIZE - sll.length))
    end

    def rewire_kernel_ip_forward(value)
      File.open('/proc/sys/net/ipv4/ip_forward', 'w') do |file|
        file.puts(value)
      end
    end

    def router(interfaces, default_gateway)
      # sock_ids = sockets.keys

      puts 'Router running...'
      packet_count = 1
      rewire_kernel_ip_forward(0)
      while true
        recv_sock = IO.select(interfaces.map(&:sock))
        timestamp = Time.now

        # Rbshark用データ
        if @options['print']
          first_timestamp = timestamp if packet_count == 1
          time_since = (timestamp - first_timestamp).to_s.split('.')
        end

        recv_sock[0].each do |sock|
          recv_interface = interfaces.select { |a| a.sock == sock }[0]
          frame = sock.recv(1024 * 8)

          # To Do: Ethernetヘッダよりframeが大きいチェック

          Rbnet::Executor.new(frame, timestamp, recv_interface, interfaces, default_gateway).exec_ether

          if @options['print']
            # 出力用のpacketデータを生成
            packet_info = Rbshark::PacketInfo.new(packet_count, time_since)
            Rbshark::Executor.new(frame, packet_info, @options['print'], @options['view']).exec_ether
          end

          packet_count += 1
        end
      end
    rescue Interrupt
      rewire_kernel_ip_forward(1)
    end

    def generate_checksum; end
  end
end
