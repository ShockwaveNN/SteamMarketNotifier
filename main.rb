#encoding: utf-8
require 'open-uri'
require 'nokogiri'

def get_page(url)
  Nokogiri::HTML(open(url))
end

def get_price_from_cheapes(xml, number = 0)
  xml.xpath("(//div[@class='market_listing_right_cell market_listing_their_price'])[#{number + 1}]/span/span[1]")[0].text.to_s.scan(/[[:print:]]/).join.gsub('€ ', '').gsub(',', '.').to_f
end


while 1
  xml = get_page('http://steamcommunity.com/market/listings/753/42140-Princess%20Mikunda')
  first_price = get_price_from_cheapes(xml)
  second_price = get_price_from_cheapes(xml, 2)
  diff = second_price - first_price
  percents = diff / second_price
  if percents > 30
    print "\a"
    p first_price
  end
  sleep 60
end
