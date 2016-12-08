module Travis
  module CronTools
    module Dependency
      class Git 
        # It's possible to provide any number of file names
        def initialize(*file_names)
          @file_names = file_names.flatten
        end

        def changed_since?(time)
          last_changed_at > time
        end

        def last_changed_at
          @last_changed_at ||= begin
            capture_or("git log -n1 --pretty=format:%cD -- #{@file_names.join(" ")}") do |err|
              raise err.with_updated_message("Could not find last changes for #{file_names.inspect}")
            end
          end
        end
      end
    end
  end
end
