# frozen_string_literal: true

require 'thor'

module Rbnet
  # CLIで受けたコマンドに対しての処理を行う
  class CLI < Thor
    class_option :interfaces, type: :string, aliases: '-i', desc: 'specify interfaces. ex) -i "eth0 eth1"'
    class_option :print, type: :boolean, aliases: '-p', default: false, desc: 'use print packet'
    class_option :view, type: :boolean, aliases: '-V', default: false, desc: 'view detailed all packets'

    def self.exit_on_failure?
      true
    end

    desc 'bridge <option>', 'run as a bridge'
    def bridge
      unless @options.key?('interfaces')
        warn 'Error: interfaces was not specified.'
        exit(1)
      end
      interfaces = @options['interfaces'].split(' ')
      Rbnet::Bridge.new(interfaces, @options).start
    end

    desc 'router <option>', 'run as a router'
    def router
      unless @options.key?('interfaces')
        warn 'Error: interfaces was not specified.'
        exit(1)
      end
      interfaces = @options['interfaces'].split(' ')
      Rbnet::Router.new(interfaces, @options).start
    end
  end
end
