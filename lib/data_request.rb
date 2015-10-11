# Class that wraps up a data request to the API
# Currently support JSON format 
# Requires an API key to access the data
# Also includes parameters of request. 
# e.g., return only fuel stations in a particular state.


class DataRequest
	attr_accessor :url, :api_key, :params, :output_format

	def initialize url, api_key, params, output_format
		@url = url
		@api_key = api_key
		@params = params
		@output_format = output_format
	end

	def get_data
		# Will return data in JSON format
		# Construct the request 
		request = @url + @params + '&api_key='+@api_key+'&format='+@output_format
		puts "\n#Request: "+request
		if @output_format.upcase == 'JSON'
			data = JSON.load(RestClient.get(request))

		#elsif @output_format.upcase == 'XML'
		#	data = Document.new(RestClient.get(request))
		end 

		return data
	end
end