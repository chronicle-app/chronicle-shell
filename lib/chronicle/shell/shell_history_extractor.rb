require 'chronicle/etl'
require 'tty-command'

module Chronicle
  module Shell
    class ShellHistoryExtractor < Chronicle::ETL::Extractor
      register_connector do |r|
        r.provider = 'shell'
        r.description = 'shell command history'
        r.identifier = 'shell-history'
      end

      BASH_TIMESTAMP_REGEX = /^\#(?<timestamp>[0-9]{10})/

      def prepare
        # TODO: determine if we're working with bash or zsh
        @shell_name = 'bash'

        @filename = history_filename
        @commands = load_commands
      end

      def results_count
        @commands.count
      end

      def extract
        @commands.each do |command|
          meta = {
            username: username,
            hostname: hostname,
            shell_name: @shell_name
          }
          yield Chronicle::ETL::Extraction.new(data: command, meta: meta)
        end
      end

      private

      def history_filename
        File.join(Dir.home, ".bash_history")
      end

      def username
        @username ||= Etc.getlogin
      end

      def hostname
        @hostname ||= begin
          require 'socket'
          Socket.gethostname
        end
      end

      def load_commands
        commands = []

        loader = "load_commands_from_#{@shell_name}"
        send(loader) do |command|
          next if @options[:load_since] && command[:timestamp] < @options[:load_since]
          next if @options[:load_until] && command[:timestamp] > @options[:load_until]

          if block_given?
            yield command
          else
            commands << command
          end
        end

        commands
      end

      def load_commands_from_bash
        timestamp = nil
        File.foreach(@filename) do |line|
          if match = line.scrub.match(BASH_TIMESTAMP_REGEX)
            timestamp = Time.at(match[:timestamp].to_i)
          elsif timestamp
            command = { timestamp: timestamp, command: line.scrub.strip }
            yield command
          end
        end
      end

      def load_commands_from_zsh
        # TODO: implement this
      end
    end
  end
end
