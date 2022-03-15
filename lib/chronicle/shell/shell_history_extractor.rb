require 'chronicle/etl'

module Chronicle
  module Shell
    class ShellHistoryExtractor < Chronicle::ETL::Extractor
      register_connector do |r|
        r.provider = 'shell'
        r.description = 'shell command history'
        r.identifier = 'history'
      end

      setting :input
      setting :shell, default: 'bash'

      BASH_TIMESTAMP_REGEX = /^\#(?<timestamp>[0-9]{10})/

      def prepare
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
            shell_name: @config.shell
          }
          yield Chronicle::ETL::Extraction.new(data: command, meta: meta)
        end
      end

      private

      # TODO: modularize the shell-specific stuff
      def history_filename
        # Ideally we coudl just use ENV['HISTFILE] but it's not available outside of Bash
        @config.input&.first || __send__("history_filename_default_#{@config.shell}")
      end

      def history_filename_default_bash
        File.join(Dir.home, ".bash_history")
      end

      def history_filename_default_zsh
        File.join(Dir.home, ".zsh_history")
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

        loader = "load_commands_from_#{@config.shell}"
        __send__(loader) do |command|
          next if @config.since && command[:timestamp] < @config.since
          next if @config.until && command[:timestamp] > @config.until

          if block_given?
            yield command
          else
            commands << command
          end
        end

        commands = commands.first(@config.limit) if @config.limit

        commands
      end

      def load_commands_from_bash
        command = nil
        File.readlines(history_filename).reverse_each do |line|
          timestamp_line = line.scrub.match(BASH_TIMESTAMP_REGEX)
          if timestamp_line && command
            timestamp = Time.at(timestamp_line[:timestamp].to_i)
            command = { timestamp: timestamp, command: command }
            yield command
          else
            command = line.scrub.strip
          end
        end
      end

      def load_commands_from_zsh
        # TODO: implement this
        raise NotImplementedError
      end
    end
  end
end
