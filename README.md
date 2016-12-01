# `spawn_travis_build`

This program provides a ruby DSL to (conditionally) spawn Travis Builds, each potentially
consisting of multiple jobs.

## Why?
Having a good Continous Integration setup is crucial for developing software.
However, running a CI test may be expensive and slow. An example is if your CI sequentiall triggers
the creation of a large number of virtual machines.

Note that the number of executed tests depends on both the frequence of build triggers and the number of tests.
This tool enables the creation of a CI pipeline that can reduce both by selectively 
running tests, and increase speed by introducing parallel execution of tests.

## Reducing the number of triggers
The first can be solved by just building the test suite afer a certain time interval, 
such as every hour, day, or week.

Travis offers Cron jobs, that can be run daily, weekly or monthly.
Therefore, we can run the expensive tests just once a day.

## Reducing number of tests
If a system is designed correctly, it is clear which parts depend on others.
We can get away with running less tests if we can filter out which changes have been made since
the last successful test, and only running the tests that actually have changed.

This logic is highly coupled with the application and therefore we have not made any attempt
provide a generic solution. Instead we suggest to use the power of Ruby to compute which
tests should be run.

We provide helper functions for checking changes in Docker Image Registries and detecting
changes in git repositories.

## Increasing speed
A Travis build can have multiple Jobs, which typically are created via the `matrix` feature
in `.travis.yml` files. 
In the DSL we provide a way to spawn new Travis Builds, each of which can have multiple Jobs.


## Suggested architecture
- Travis Cron Job triggered
- Write logic in DSL
- Fetch code from GitHub
- `if [[ $TRAVIS_JOB == "cron" ]]; then spawn_travis_build ./travis/cron.rb; fi


## Installation
Or the gem with:

    $ gem install spawn_travis_build


## Development
After checking out the repo, run `bundle install` to install gem dependencies. 
Then, run `rake test` to run the tests.
You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.
To release a new version, update the version number in `version.rb`, and then run 
`bundle exec rake release`, which will create a git tag for the version, push git commits and tags,
  and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing
Bug reports and pull requests are welcome on GitHub at https://github.com/microservices-demo/spawn_travis_build.
This project is intended to be a safe, welcoming space for collaboration, and contributors are
expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
