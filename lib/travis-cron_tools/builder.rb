module Travis
  module CronTools
    class BuildBuilder
      attr_reader :jobs

      def initialize
        @jobs = []
      end

      def add_job(job)
        @jobs.push job
      end
    end
  end
end
