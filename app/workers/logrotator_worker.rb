module App
  module Workers
    class LogrotatorWorker

      @@log_file = %w(production.log logstash_production.log rails_rpc_server.log rails_ViolationRPC_server.log RTS.log bullet.log)

      def initialize(opts = {})
        @options = opts
      end

      def run
        @@log_file.each do |file_name|
          file_path = File.join(Rails.root, 'log', file_name)
          if File.exists?(file_path)
            # if this log file exists, i am going to copy this log file to a new log file with yesterday's timestamp
            timestamp_file_name = Time.zone.yesterday.to_s + "-" + file_name
            new_file_path = File.join(Rails.root, 'log', timestamp_file_name)
            FileUtils.cp(file_path, new_file_path)
            # now we need to clean all previous content in this logfile
            File.open(file_path, 'w')
          end
        end
      end
    end
  end
end