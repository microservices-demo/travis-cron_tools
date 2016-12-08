require "travis-cron_tools"

# Instantiate travis client for this repository.
travis = Travis::CronTools::TravisAPI.new("microservices-demo", "microservices-demo")

###############################################################################
# Find time to compare changes against
###############################################################################

# Find time to compare changes against
# This guarrantees that we won't miss any changes.

last_cron_job = travis.builds(event_type: "cron").first
last_cron_job_start_time = Time.parse(last_cron_job["started_at"])

last_cron_job_start_time = (Date.today - 30).to_time

puts "Checking for changes after #{last_cron_job_start_time.rfc2822}"

###############################################################################
# Find dependencies
###############################################################################

# Declare the latest nginx docker image to be a dependency
nginx_dep = Travis::CronTools::Dependency::Docker.new("nginx")

# It is also possible to specify a specific image tag
mysql= Travis::CronTools::Dependency::Docker.new("mysql", "8.0")

# In the contrib module, there are some helper methods.
# Below for example, it extracts all image names from a k8s manifest file.
k8s_docker_images = Travis::CronTools::Contrib.find_images_in_k8s_manifest("path/to/k8s.yml")

all_docker_images = k8s_docker_images + [nginx_dep, mysql]

# Domain specific struct to encode a custom dependency
Platform = Struct.new(:name, :dir)

# and compute the domain specific dependencies
platforms = Dir["deploy/*"] \
  .select { |file_name| File.directory? file_name } \
  .map { |file_name| Platform.new(File.basename(file_name), file_name) }

###############################################################################
# Determine which tests to run
###############################################################################

platforms_to_test = []

# Implement custom logic to determine what  should be tested.
# In this case, if any of the docker images has changed, we want to test
# all different platforms we can deploy to.
if all_docker_images.any? { |image| image.created_since?(last_cron_job_start_time) }
  puts "Some of the docker images changed; building all platforms"
  platforms_to_test = platforms
else
  # Alternatively, if none of the images has changed, we check if any deployment has changed
 # in the git repository since the last successfull build.
 puts "None of the docker images changed."
 platforms.each do |platform| 
    git_dir = SpawnTravisBuild::Dependency::Git.new(platform.dir)
    if git_dir.changed_since?(last_cron_job_start_time)
      puts "However, deployment platform #{platform.name} changed"
      platforms_to_test.push platform
    end
  end
end

###############################################################################
# Create Travis Build
###############################################################################

# Now we create the travis build.
# Note that we use the reset_dot_travis_yml helper; this configuration is MERGED with
# the existing configuration

cron_build_number = ENV["TRAVIS_BUILD_NUMBER"]
travis_build_request = {
  message: "[deployment-daily-ci] spanwed by cron build #{cron_build_number}",
  branch: ENV["TRAVIS_COMMIT"],
  config: Travis::CronTools.reset_dot_travis_yml.merge({
    language: "generic",
    sudo: true,
    services: ["docker"],
    env: {
      matrix: platforms_to_test.map { |platform| "PLATFORM_TO_TEST=#{platform.name}" }
    },
    script: ["run_testsuite --test $PLATFORM_TO_TEST"]
  })
}

p travis_build_request
#travis.create_request(travis_build_request)
