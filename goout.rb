#!/usr/bin/env ruby

require 'kimurai'
require 'json'

CRAWLER_DATA_DIR = ENV['CRAWLERS_DATA_DIR']
LINK_DOMAIN = "https://goout.net"
FILE_NAME = "goout_newly_announced.json"
FULL_PATH = "#{CRAWLER_DATA_DIR}/#{FILE_NAME}"


class GoOutSpider < Kimurai::Base
  @name = "GoOut_Spider"
  @engine = :mechanize
  @start_urls = ["https://goout.net/cs/praha/akce/?sort=newly_announced"]

  def parse(response, url:, data: {})
    if File.file?(FULL_PATH) then
      file = File.open FULL_PATH
      loaded = JSON.load(file).map {|record| OpenStruct.new(record)}
      file.close
    end

    countUpdated = 0

    response.css('.eventCard .info').each do |card|
      event = OpenStruct.new({
        :name => card.css('span[itemprop=name].name').text.squish,
        :link => "#{LINK_DOMAIN}#{card.css('a').attribute('href')}",
        :venue => card.css('.venue span[itemprop=name]').text.squish,
        :venueLink => "#{LINK_DOMAIN}#{card.css('.venue span[itemprop=geo]').attribute('data-venue-href')}",
        :dateTime => card.css('time').attribute('datetime'),
        :scrapeDate => Time.now.to_s,
      })
      if loaded then
        found = loaded.detect { |item| item.link == event.link }
        event.scrapeDate = found.scrapeDate if found
      end
      countUpdated += 1 unless found

      Dir.mkdir(CRAWLER_DATA_DIR) unless Dir.exists? CRAWLER_DATA_DIR
      save_to FULL_PATH, event.to_h(), format: :pretty_json
    end
    puts "Update #{countUpdated} items."
  end
end

GoOutSpider.crawl!
