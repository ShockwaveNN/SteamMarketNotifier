#encoding: utf-8
require 'open-uri'
require 'nokogiri'
require 'gmail'
require 'json'

USD_IN_RUB = 0.03
USD_IN_EUR = 1.36
URL_ITEM = 'http://steamcommunity.com/market/listings/753/33680-Princess%20Nehema'

def get_page(url)
  Nokogiri::HTML(open(url))
end

def get_prices(xml)
  prices_array = []
  (0..9).each do |i|
    prices_array << xml.xpath("(//div[@class='market_listing_right_cell market_listing_their_price'])[#{i + 1}]/span/span[1]")[0].text.to_s.scan(/[[:print:]]/).join.gsub(',', '.')
  end
  prices_array
end


def convert_price(prices_array)
  converted = []
  prices_array.each do |cur_price|
    price = nil
    cur_price.gsub!('--', '00')
    if cur_price.include?('pуб')
      price_rub = cur_price.gsub(' pуб.', '').to_f
      price = price_rub * USD_IN_RUB
    elsif cur_price.include?('€')
      price_rub = cur_price.gsub('€ ', '').to_f
      price = price_rub * USD_IN_EUR
    elsif cur_price.include?('USD')
      price_rub = cur_price.gsub(' USD', '').gsub('$', '').to_f
      price = price_rub
    end
    converted << price
  end
  converted
end

def notify
  settings_string = File.open('Mail.config').read
  setttings = JSON[settings_string]
  gmail = Gmail.new(setttings['mail_sender'], setttings['mail_sender_password'])
  email = gmail.generate_message do
    to setttings['mail_to_notify']
    subject "Steam Market Notifier"
    body URL_ITEM
  end
  email.deliver!
  gmail.logout
end

notify
while 1
  xml = get_page(URL_ITEM)
  prices = get_prices(xml)
  converted = convert_price(prices)
  if converted[0] / converted[1] < 0.99
   notify
  end
  sleep 10
end
