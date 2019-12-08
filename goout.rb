#!/usr/bin/env ruby

require 'kimurai'
require 'json'

CRAWLER_DATA_DIR = ENV['CRAWLERS_DATA_DIR']
LINK_DOMAIN = 'https://goout.net'.freeze
FILE_NAME = 'goout_newly_announced.json'.freeze
SORT_METHOD = 'sort=newly_announced'.freeze

class GoOutSpider < Kimurai::Base
  @name = 'GoOut_Spider'
  @engine = :mechanize
  @categories = %w[
    events
    concerts
    plays
    exhibitions
    movies
    parties
    festivals
    culinary
    for-children
    other-events
  ]
  @start_urls = @categories.map do |category|
    {
      url: "#{LINK_DOMAIN}/en/prague/#{category}/?#{SORT_METHOD}",
      data: "#{CRAWLER_DATA_DIR}/#{category}_#{FILE_NAME}"
    }
  end

  def create_card(card)
    OpenStruct.new(
      name: card.css('span[itemprop=name].name').text.squish,
      link: "#{LINK_DOMAIN}#{card.css('a').attribute('href')}",
      venue: card.css('.venue span[itemprop=name]').text.squish,
      venueLink: "#{LINK_DOMAIN}#{card.css('.venue span[itemprop=geo]')
        .attribute('data-venue-href')}",
      dateTime: card.css('time').attribute('datetime'),
      scrapeDate: Time.now.to_s
    )
  end

  def load_data(data_path)
    return unless File.file?(data_path)

    file = File.read data_path
    JSON.parse(file).map { |record| OpenStruct.new(record) }
  end

  def ensure_data_dir
    Dir.mkdir(CRAWLER_DATA_DIR) unless Dir.exist? CRAWLER_DATA_DIR
  end

  def parse(response, url)
    loaded = load_data url[:data]
    count_updated = 0

    response.css('.eventCard .info').each do |card|
      event = create_card card
      if loaded
        found = loaded.detect { |item| item.link == event.link }
        event.scrapeDate = found.scrapeDate if found
      end
      count_updated += 1 unless found
      ensure_data_dir
      save_to url[:data], event.to_h, format: :pretty_json
    end
    puts "Update #{count_updated} items."
  end
end

GoOutSpider.crawl!
