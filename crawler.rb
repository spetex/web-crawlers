#!/usr/bin/env ruby

require 'kimurai'
require 'json'

LINK_DOMAIN = "https://goout.net"
FILE_NAME = "data/goout_newly_announced.json"


class GoOutSpider < Kimurai::Base
  @name = "GoOut_Spider"
  @engine = :mechanize
  @start_urls = ["https://goout.net/cs/praha/akce/?sort=newly_announced"]

  def parse(response, url:, data: {})
    file = File.open FILE_NAME
    loaded = JSON.load file
    file.close

    countUpdated = 0

    response.css('.eventCard .info').each do |card|
      event = {
        :name => card.css('span[itemprop=name].name').text.squish,
        :link => "#{LINK_DOMAIN}#{card.css('a').attribute('href')}",
        :venue => card.css('.venue span[itemprop=name]').text.squish,
        :venueLink => "#{LINK_DOMAIN}#{card.css('.venue span[itemprop=geo]').attribute('data-venue-href')}",
        :dateTime => card.css('time').attribute('datetime'),
        :scrapeDate => Time.now.to_s,
      }
      found = loaded.detect { |item| item["link"] == event[:link] }
      event[:scrapeDate] = found["scrapeDate"] if found
      countUpdated += 1 unless found
      save_to FILE_NAME, event, format: :pretty_json
    end
    puts "Update #{countUpdated} items."
  end
end

GoOutSpider.crawl!
