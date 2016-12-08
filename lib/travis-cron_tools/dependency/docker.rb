module Travis
  module CronTools
    module Dependency
      class Docker
        class DockerError < RuntimeError
        end

        attr_reader :name
        attr_reader :tag


        def initialize(name, tag="latest")
          @name = name
          @tag = tag
        end

       def created_since?(time)
         created_at > time
       end

       def created_at
         Time.parse(metadata["Created"])
       end

       def metadata
         @metadata ||= begin
           log, status = Open3.capture2e("docker pull #{full_name}")
           if !status.success?
             raise DockerError.new("Could not pull #{full_name}; #{log}")
           end

           output, status = Open3.capture2e("docker inspect #{full_name}")
           if !status.success?
             raise err.with_updated_message("Could pull, but not inspect docker image #{name}:#{tag}; #{output}")
           end

           JSON.load(output).first
         end
       end

       def full_name
         "#{name}:#{tag}"
       end
      end
    end
  end
end
