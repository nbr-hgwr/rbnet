# frozen_string_literal: true

require 'thor'

module Rbnet
  # CLIで受けたコマンドに対しての処理を行う
  class CLI < Thor
    class_option :interfaces, type: :string, aliases: '-i', desc: 'specify interfaces. ex) -i "eth0 eth1"'

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
      Rbnet::Bridge.new(interfaces).start
    end
  end
end