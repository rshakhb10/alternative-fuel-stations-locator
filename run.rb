# Uses 2 APIs from National Renewable Energy Laboratory (NREL, http://developer.nrel.gov)
# about Alternative fuel stations.
# 1st API has all the information about alternative fuel stations 
# 2nd API is about all alt fuel stations near to the location of interest

# Accessing the data requires the API key that can be generated on their website
# Number of requests to web services that can be done in one hour is limited to 1000
# after that the key is temporarily deactivated.

require 'json'
require 'rest-client'
#require 'rexml/document'
#include REXML
require_relative 'lib/data_request'
require_relative 'lib/fuel_station'
require_relative 'lib/location'


#################################################
#Functions
#################################################
# Print out all available options
options = []
options <<  "1. Find information about all alternative fuel stations in a particular state. (e.g., RI, MA, MN)\n"
options <<  "2. Find information about all alternative fuel stations in a particular zipcode. (e.g., 02139)\n"
options <<  "3. Find information about all alternative fuel stations of particular type. (e.g., biodiesel, electric, ethanol)\n"
options <<  "4. Find information about all alternative fuel stations in 5mi radius to your location of interest. (e.g., 51 Melcher Street)\n"

def print_options options
	puts "\n--------------------------------- Available options ------------------------------------\n\n"
	puts options
	puts "\n-----------------------------------------------------------------------------------------\n"
	puts "\nSelect one of the options by number.\n"
end

#################################################
# Validate user input
def check_input user_input, options
	# Convert the input to integer and check if the number provided is within
	# number of available options 
	# Exit the program if the input is in wrong format
	if user_input.to_i > options.size or user_input.to_i <=0 or user_input =~ /[^0-9]/
		puts "\n### ERROR: Invalid input. Please provide number from 1 to #{options.size} ###\n"
		abort
	end
end

#################################################
# Depending on what option was selected ask for particular input
# and return corresponding parameters that will be provided in the 
# API request and API URL
def get_params user_input
	params = ""
	url_key = ""
	additional_params = ""

	
	if user_input == 1
		puts "\nPlease provide state name as a 2-letter code.\n"
		state = gets.strip.chomp.upcase

		if state.length != 2 or state =~ /[0-9]|\W/ 
			puts "\n##ERROR: State should be a 2-letter code.\n"
			abort
		end

		params = "state="+state
		url_type = "general_info_url"

	elsif user_input == 2

		puts "\nPlease provide zipcode.\n"
		zipcode = gets.strip.chomp

		if zipcode=~ /[^0-9]/   # check if contains any non digit characters
			puts "\n##ERROR: Zipcode can only contain numbers.\n"
			abort

		elsif zipcode.length > 5
			puts "\n##ERROR: Zipcode should be a 5-digit code.\n"
			abort
		end

		params = "zip="+zipcode
		url_type = "general_info_url"

	elsif user_input == 3
		puts "\nPlease provde fuel type code. Select one of these codes:\n"
		puts " -- BD (Biodiesel)"
		puts " -- CNG (Compressed Natural Gas)"
		puts " -- E85	(Ethanol)"
		puts " -- ELEC (Electric)"
		puts " -- HY (Hydrogen)"
		puts " -- LNG (Liquefied Natural Gas)"
		puts " -- LPG (Liquefied Petroleum Gas (Propane)"

		fuel_type = gets.strip.chomp.upcase

		if fuel_type =~ /\W/ or fuel_type.length == 0
			puts "\n##ERROR: Fuel type code can't be blank or have spaces or non-letter characters.\n"
			abort
		end

		params = "fuel_type="+fuel_type
		url_type = "general_info_url"


	elsif user_input == 4
		puts "\nPlease provide location of interest. Can be in variable format, e.g.:\n"
		puts " -- street city state postal code\n"
		puts " -- street city state\n"
		puts " -- street postal code\n"
		puts " -- postal code\n"
		puts " -- city state\n"

		location = gets.strip.chomp
		if location !~ /\w|[0-9]/ or location.length == 0 
			puts "\n##ERROR: Location code can't be blank.\n"
			abort
		end

		# Split the input and convert to format accepted in the API request
		fields = location.split(/\W+/)
		if fields.size == 1
			params = "location="+fields[0]
		else
			params = "location="+fields.join("+")
		end
		
		url_type = "nearest_station_url"
	end

	return params, url_type
end

# Get API info from the config
def get_api_info config
	#conf = JSON.load(config)
	file = File.read(config)
    conf_data = JSON.parse(file)
	return conf_data
end 

##################################################
# Main 
#
# Print out options 
print_options(options)

# Get input and validate
input = gets.strip.chomp
check_input(input, options)

# Get parameters to be submitted as part of API reuqest
params, url_type = get_params(input.to_i)

#Parse config with API credentials
conf = get_api_info("fuel_stations_config.json")
api_url = conf["fuel_stations_url"][url_type]
api_key = conf["api_key"]
output_format = conf["output_format"]

#Send request
puts "\n##########################################\n"
puts "\nSending request...\n"
fuel_stations_request = DataRequest.new(api_url, api_key, params, output_format)

# Getting data
puts "\n##########################################\n"
puts "\nGetting data back. Might take a moment...\n"
data = fuel_stations_request.get_data()
puts "\n##########################################\n"


# Check if there are any data for this request
# and print out results
stations = []
if data["total_results"].to_i !=0
	data["fuel_stations"].each do |entry|
    location = FuelStationLocation.new(entry["street_address"], entry["city"], entry["state"])
    fuel_station = FuelStation.new(location, entry["station_name"], entry["fuel_type_code"])

    stations << fuel_station
	end
else
	puts "\nNo fuel stations were found for your request.\n"
end

# Release the raw data from memory
data = nil

if !stations.empty?
	# Print out the entries
	puts "Were found "+stations.size.to_s+ " stations:\n"
	stations.each_with_index do |s, index|
		puts "#{index+1}. #{s}"
	end
end


