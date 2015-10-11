# Location of alternative fuel stations

class FuelStationLocation
	attr_accessor :street, :city, :state
	#:nearby_route, :longitude, :latitude

	def initialize(street, city, state)
		@street = street
		@city = city
		@state = state
	end

	def to_s
		"#{street}, #{city}, #{state}."
	end

end