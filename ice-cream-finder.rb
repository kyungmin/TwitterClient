require 'rest-client'
require 'addressable/uri'
require 'json'

class IceCreamFinder
  def self.url_to_coord(url)
    response = RestClient.get(url)
    response = JSON.parse(response)
    response = response["results"].first
    response = response["geometry"]
    response = response["location"]
    [response["lat"], response["lng"]]
  end

  def self.create_url(address)
    address_str = address.gsub(/\s+/, '+')
    Addressable::URI.new(
      :scheme => "http",
      :host => "maps.googleapis.com",
      :path => "maps/api/geocode/json",
      :query_values => {:address => address_str, :sensor => false}
    ).to_s
  end
end