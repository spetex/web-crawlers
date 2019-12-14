#!/usr/bin/env ruby

require 'kimurai'
require 'json'

CRAWLER_DATA_DIR = ENV['CRAWLERS_DATA_DIR']
LINK_DOMAIN = 'https://puttyandpaint.com/projects/'.freeze
FILE_NAME = 'puttyandpaint.json'.freeze

class GoOutSpider < Kimurai::Base
  @name = 'GoOut_Spider'
  @engine = :mechanize
  @categories = %w[
    editors-choice
    all-projects
  ]
  @start_urls = @categories.map do |category|
    {
      url: "#{LINK_DOMAIN}#{category}",
      data: "#{CRAWLER_DATA_DIR}/#{category}_#{FILE_NAME}"
    }
  end

  def extract_data(card)
    OpenStruct.new(
      name: card.css('a').attribute('title'),
      link: "#{card.css('a').attribute('href')}",
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

    response.css('.project-list li').each do |card|
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
