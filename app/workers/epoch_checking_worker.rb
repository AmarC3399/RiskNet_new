module App
  module Workers
    class EpochCheckingWorker
      def run
        EpochObserverService.check_server_epoch
      end
    end
  end
end
