module Travis
  module CronTools
    def self.running_on_travis?
      ENV.has_key?("TRAVIS_EVENT_TYPE")
    end

    DOT_TRAVIS_YML_WHITELIST = ["notifications"]
    def self.reset_dot_travis_yml(path=".", whitelist=DOT_TRAVIS_YML_WHITELIST)
      reset = {}
      yaml = YAML.load(File.read(File.join(path, ".travis.yml")))

      yaml.each do |key, value|
        if DOT_TRAVIS_YML_WHITELIST.include?(key)
          reset[key] = value
        else
          reset_value = case value
                        when Hash then {}
                        when Array then []
                        when FalseClass then nil
                        when TrueClass then nil
                        when String then nil
                        when Numeric then nil
                        else raise("Unknown reset value for #{value.class} #{value.inspect}")
                        end
          reset[key] = reset_value
        end
      end

      reset
    end
  end
end
