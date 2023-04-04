module App
  module Workers
    class HeartbeatWorker

      def run
        puts "running Heartbeat msg"
        LogMailer.heartbeat_email.deliver
        puts "running Heartbeat msg COMPLETE!"
      end

    end
  end
end