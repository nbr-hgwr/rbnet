# frozen_string_literal: true

require 'thor'

module Rbnet
  # CLIで受けたコマンドに対しての処理を行う
  class CLI < Thor
    class_option :interface, type: :string, aliases: '-i', desc: 'specify interface. ex) -i eth0'

    def self.exit_on_failure?
      true
    end

    desc 'bridge <option>', 'run as a bridge'
    def bridge
      unless @options.key?('interface')
        warn 'Error: interfaces was not specified.'
        exit(1)
      end
    end
  end
end