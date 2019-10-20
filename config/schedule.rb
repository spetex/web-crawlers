# Use this file to easily define all of your cron jobs.
env 'CRAWLERS', 'path/to/crawlers/folder'

every 30.minutes do
  command "exec $CRAWLERS/crawler.rb"
end

# Learn more: http://github.com/javan/whenever
