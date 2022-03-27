# frozen_string_literal: true

module Rbnet
  ETH_P_ALL             = 0x0300
  ETH_P_IP              = 0x0800
  ETH_P_IPV6            = 0x86dd
  ETH_P_ARP             = 0x0806
  SIOCGIFINDEX          = 0x8933
  SIOCGIFCONF           = 0x8912
  SIOCGIFNAME           = 0x8910
  SIOCGIFFLAGS          = 0x8913
  SIOCGIFHWADDR         = 0x8927
  IFREQ_SIZE            = 0x0028 # sizeof(ifreq) on 64bit
  IFINDEX_SIZE          = 0x0004 # sizeof(ifreq.ifr_ifindex) on 64bit
  SOCKADDR_LL_SIZE      = 0x0014 # sizeof(sockaddr_ll) on 64bit
end
