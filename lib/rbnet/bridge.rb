# frozen_string_literal: true

require 'socket'
require 'rbshark'

module Rbnet
  class Bridge
    def initialize(interfaces_name, options)
      @interfaces_name = interfaces_name
      @options = options
    end

    def start
      sockets = {}
      for i in 1..@interfaces_name.size
        obj = Socket.open(Socket::AF_PACKET, Socket::SOCK_RAW, Rbnet::ETH_P_ALL)
        sockets[obj.object_id.to_s] = obj
      end

      sockets.each_with_index do |soc, i|
        if_num = Rbnet::Interface.new.get_interface(soc[1], @interfaces_name[i])
        soc[1].bind(sockaddr_ll(if_num))
      end

      bridge(sockets)
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

    def bridge(sockets)
      sock_ids = sockets.keys
      begin
        puts 'Bridge running...'
        packet_count = 1
        rewire_kernel_ip_forward(0)
        while true
          recv_sock = IO::select(sockets.values)

          if @options['print']
            timestamp = Time.now
            first_timestamp = timestamp if packet_count == 1
            time_since = (timestamp - first_timestamp).to_s.split('.')
          end

          recv_sock[0].each do |sock|
            frame = sock.recv(1024*8)

            # 出力用のpacketデータを生成
            packet_info = Rbshark::PacketInfo.new(packet_count, time_since) if @options['print']
            Rbshark::Executor.new(frame, packet_info, @options['print'], @options['view']).exec_ether

            send_sock = sock.object_id.to_s === sock_ids[0] ? sockets[sock_ids[1]] : sockets[sock_ids[0]]
            send_sock.send(frame, 0)
            packet_count += 1
          end
        end
      rescue Interrupt
        rewire_kernel_ip_forward(1)
      end
    end
  end
end