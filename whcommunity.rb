#!/usr/bin/env ruby

require 'kimurai'
require 'json'

CRAWLER_DATA_DIR = ENV['CRAWLERS_DATA_DIR']
LINK_DOMAIN = 'https://www.warhammer-community.com/'.freeze
FILE_NAME = 'whcommunity.json'.freeze

class GoOutSpider < Kimurai::Base
  @name = 'GoOut_Spider'
  @engine = :mechanize
  @categories = %w[
    warhammer-40000-news
    warhammer-40000
    warhammer-age-of-sigmar-news
    warhammer-age-of-sigmar
    black-library-news
    black-library
    horus-heresy-news
    horus-heresy
    forge-world-news
    forge-world
    store-news
  ]
  @start_urls = @categories.map do |category|
    {
      url: "#{LINK_DOMAIN}#{category}",
      data: "#{CRAWLER_DATA_DIR}/#{category}_#{FILE_NAME}"
    }
  end

  def extract_data(card)
    OpenStruct.new(
      name: card.css('h3').text,
      link: "#{card.attribute('href')}",
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

    response.css('.standard_posts > a').each do |card|
      post = extract_data card
      if loaded
        found = loaded.detect { |item| item.link == post.link }
        post.scrapeDate = found.scrapeDate if found
      end
      count_updated += 1 unless found
      ensure_data_dir
      save_to url[:data], post.to_h, format: :pretty_json
    end
    puts "Update #{count_updated} items."
  end
end

GoOutSpider.crawl!
