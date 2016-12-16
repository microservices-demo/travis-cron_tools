module Travis
  module CronTools
    module Contrib
      def self.find_images_in_k8s_manifest(*manifest_paths)
        images = []

        manifest_paths.each do |manifest_path|
          # A manifest may contain multiple YAML 'documents'
          yaml_parts = File.read(manifest_path)\
            .split("---\n")\
            .map { |part| YAML.load(part) }

          # Extract the image name, and append ':latest', unless a tag has already been provided.
          images += yaml_parts\
            .select { |part| !! part } \
            .select { |part| part["kind"] == "Deployment" }\
            .map { |part| part["spec"]["template"]["spec"]["containers"].map { |c| c["image"] } }.flatten\
            .map { |name| if name.include?(":") then name; else name + ":latest"; end }
        end

        images.uniq.map do |name|
          Dependency::Docker.new(*name.split(":"))
        end
      end
    end
  end
end
