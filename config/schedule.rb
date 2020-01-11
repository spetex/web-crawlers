# Use this file to easily define all of your cron jobs.
env 'CRAWLERS', ENV['CRAWLERS_DIR']
env 'CRAWLERS_ENV', ENV['CRAWLERS_RUBY_GEMSET']
env 'CRAWLERS_DATA_DIR', ENV['CRAWLERS_DATA_DIR']
env 'CRAWLERS_LOG_FILE', ENV['CRAWLERS_LOG_FILE']
env 'RUBY_VERSION', ENV['RUBY_VERSION']

every 30.minutes do
  command 'exec rvm $RUBY_VERSION@$CRAWLERS_ENV do ruby $CRAWLERS/goout.rb >> $CRAWLERS_LOG_FILE'
  command 'exec rvm $RUBY_VERSION@$CRAWLERS_ENV do ruby $CRAWLERS/puttyandpaint.rb >> $CRAWLERS_LOG_FILE'
  command 'exec rvm $RUBY_VERSION@$CRAWLERS_ENV do ruby $CRAWLERS/whcommunity.rb >> $CRAWLERS_LOG_FILE'
end

# Learn more: http://github.com/javan/whenever
