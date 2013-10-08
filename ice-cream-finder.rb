require 'rest-client'
require 'addressable/uri'
require 'json'
require 'nokogiri'

class IceCreamStore
  attr_accessor :name, :address, :location

  def initialize(name, address, location)
    @name, @address, @location = name, address, location
  end
end

class IceCreamFinder
  def self.url_to_coord(url)
    response = RestClient.get(url)
    response = JSON.parse(response)
    response = response["results"].first
    response = response["geometry"]
    response = response["location"]
    "#{response["lat"]},#{response["lng"]}"
  end

  def self.create_url_for_geocoding(address)
    address_str = address.gsub(/\s+/, '+')
    Addressable::URI.new(
      :scheme => "http",
      :host => "maps.googleapis.com",
      :path => "maps/api/geocode/json",
      :query_values => { :address => address_str, :sensor => false }
    ).to_s
  end

  def self.create_url_for_place(coord)
    Addressable::URI.new(
      :scheme => "https",
      :host => "maps.googleapis.com",
      :path => "maps/api/place/textsearch/json",
      :query_values => {:query => "ice+cream",
                        :sensor => false,
                        :key=>"AIzaSyAu5qwvIIDcKQHMb1Mdy70CAX4D0ssXZi4",
                        :location => coord, :radius => "50"
                        }
    ).to_s
  end

  def self.get_ice_cream_coord(url)
    response = RestClient.get(url)
    response = JSON.parse(response)
    response = response["results"][0..9]
    ice_cream_stores = []

    response.each do |ice_cream_store|
      name = ice_cream_store["name"]
      address = ice_cream_store["formatted_address"]
      lat_and_lng = ice_cream_store["geometry"]["location"]
      coord_str = "#{lat_and_lng["lat"]},#{lat_and_lng["lng"]}"

      ice_cream_stores << IceCreamStore.new(name, address, coord_str)
    end

    ice_cream_stores
  end

  def self.create_url_for_direction(origin, destination)
    Addressable::URI.new(
      :scheme => "https",
      :host => "maps.googleapis.com",
      :path => "maps/api/directions/json",
      :query_values => { :origin => origin,
                         :destination => destination,
                         :mode => "walking",
                         :sensor => false
                       }
    ).to_s
  end

  def self.display_directions(url)
    response = RestClient.get(url)
    response = JSON.parse(response)
    response = response["routes"].first
    response = response["legs"].first
    steps = response["steps"]
    steps.each do |step|
      direction_steps =  Nokogiri::HTML(step["html_instructions"]).text
      puts direction_steps.gsub("Destination", "\nDestination")
    end


  end

  def self.get_directions(address)
    origin_url = create_url_for_geocoding(address)
    origin_coord = url_to_coord(origin_url)
    places_url = create_url_for_place(origin_coord)
    ice_cream_stores = get_ice_cream_coord(places_url)

    ice_cream_stores.each do |ice_cream_store|
      puts ice_cream_store.name
      puts ice_cream_store.address
      direction_url = create_url_for_direction(origin_coord, ice_cream_store.location)
      display_directions(direction_url)
      puts
    end
  end
end

