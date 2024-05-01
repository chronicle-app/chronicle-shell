require 'chronicle/etl'
require 'chronicle/models'

module Chronicle
  module Shell
    class ShellHistoryTransformer < Chronicle::ETL::Transformer
      register_connector do |r|
        r.source = :shell
        r.type = :command
        r.strategy = :local
        r.description = 'a shell command'
        r.from_schema = :extraction
        r.to_schema = :chronicle
      end

      def transform(record)
        username = record.extraction.meta[:username]
        hostname = record.extraction.meta[:hostname]
        shell_name = record.extraction.meta[:shell_name]
        timestamp = record.data[:timestamp]
        command = record.data[:command]

        build_command(username:, hostname:, command:, shell_name:,
          timestamp:)
      end

      private

      def build_command(username:, hostname:, command:, shell_name:, timestamp:)
        Chronicle::Models::ControlAction.new do |r|
          r.source = shell_name
          r.result = build_command_result(command)
          r.agent = build_agent(username, hostname)
          r.end_time = timestamp
          # r.object = build_host
          r.dedupe_on << %i[source type end_time]
        end
      end

      def build_command_result(text)
        Chronicle::Models::ComputerCommand.new do |r|
          r.text = text
          r.source = 'system'
          r.dedupe_on << %i[source text type]
        end
      end

      def build_agent(username, hostname)
        Chronicle::Models::Person.new do |r|
          r.source = 'system'
          r.slug = build_user_slug(username, hostname)
          r.dedupe_on << %i[source slug type]
        end
      end

      # TODO: implement this.
      # TODO: figure out how to represent the host in schema
      def build_host(hostname); end

      def build_user_slug(username, hostname)
        "#{username}@#{hostname}"
      end
    end
  end
end
