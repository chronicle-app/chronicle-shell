require 'chronicle/etl'

module Chronicle
  module Shell 
    class ShellHistoryTransformer < Chronicle::ETL::Transformer
      register_connector do |r|
        r.provider = 'shell'
        r.description = 'a shell command'
        r.identifier = 'command'
      end

      def transform
        @command = @extraction.data
        build_commanded
      end

      def id
      end

      def timestamp
        @command[:timestamp]
      end

      private

      def build_commanded
        record = ::Chronicle::ETL::Models::Activity.new
        record.verb = 'commanded'
        record.end_at = timestamp
        record.provider = @extraction.meta[:shell_name]
        record.dedupe_on << [:verb, :end_at, :provider]
        record.involved = build_command
        record.actor = build_actor
        record
      end

      def build_command
        record = ::Chronicle::ETL::Models::Entity.new
        record.represents = 'command'
        record.provider = @extraction.meta[:shell_name]
        record.body = @command[:command]
        record.dedupe_on << [:body, :provider, :represents]
        record
      end

      def build_actor
        record = ::Chronicle::ETL::Models::Entity.new
        record.represents = 'identity'
        record.provider = 'system'
        record.slug = build_user_slug
        record.dedupe_on << [:represents, :provider, :slug]
        record
      end

      def build_user_slug
        "#{@extraction.meta[:username]}@#{@extraction.meta[:hostname]}"
      end
    end
  end
end
