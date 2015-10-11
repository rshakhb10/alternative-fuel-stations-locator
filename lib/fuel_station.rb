# Class wrapping alternative fuel station information

class FuelStation
	attr_accessor :location, :station_name, :fuel_type

	def initialize (location, station_name, fuel_type)
        @location = location
		@station_name = station_name
		@fuel_type = fuel_type
	end
	
	def to_s
		"'#{station_name}' station with fuel type #{fuel_type} located at #{location}"
	end

end