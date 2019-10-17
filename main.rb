require 'sinatra'
require 'kimurai'

class GoOutSpider < Kimurai::Base
  @name = "GoOut_Spider"
  @engine = :mechanize
  @start_urls = ["https://goout.net/cs/praha/akce/?sort=newly_announced"]

  def parse(response, url:, data: {})
    events = []
    response.css('.eventCard .info').each do |card|
      event = {
        :name => card.css('span[itemprop=name].name').text,
        :link => card.css('a').attribute('href'),
        :venue => card.css('.venue span[itemprop=name]').text,
        :venueLink => card.css('.venue span[itemprop=geo]').attribute('data-venue-href'),
        :dateTime => card.css('time').attribute('datetime'),
      }
      events.push event
    end
    events
  end
end



get '/' do
  events = GoOutSpider.parse!(:parse, url:"https://goout.net/cs/praha/akce/?sort=newly_announced" )
  events[0][:name]
end
