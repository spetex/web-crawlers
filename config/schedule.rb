# Use this file to easily define all of your cron jobs.
env 'CRAWLERS', ENV['CRAWLERS_DIR']
env 'CRAWLERS_ENV', ENV['CRAWLERS_RUBY_GEMSET']
env 'CRAWLERS_DATA_DIR', ENV['CRAWLERS_DATA_DIR']

every 30.minutes do
  command "exec rvm ruby@$CRAWLERS_ENV do ruby $CRAWLERS/goout.rb"
end

# Learn more: http://github.com/javan/whenever
