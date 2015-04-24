class DisavowsController < ApplicationController
	require "open-uri"

	def index
		@disavow = Disavow.all #This is an array of hashes. Each hash represents a disavow.
		#id = @disavow[2][:api_record_id] This is how you get the api record from the hash. In this case I would be getting the info of the hash in index 2
		api_record_ids = @disavow.map {|h| h[:api_record_id]} #This array holds all the api_record_id values for each disavow
		record_info_holder = Hash.new
		api_record_ids.each { |api_id|
			api_record = get_record_by_id(api_id)
			record_info_holder[api_id] = api_record["business_detail"]["business_name"], api_record["business_detail"]["website"], api_record["business_detail"]["industry"]
		}
		@record_business_details = record_info_holder.values
	end

	def show
	end

	def search
		#This method is used only for rendering the search form
	end

	def search_result
		business_name = params[:business_name].to_s #The string inputted by the user in to the text box
		url = URI.escape("http://clientcloud.herokuapp.com/search?key=#{ENV["APPLICATION_KEY"]}&q=#{business_name}")
		response = open(url).read
		@search_results = JSON.parse(response)
		render "search"
	end

	def new
		id = params[:id].to_s
		api_record = get_record_by_id(id)

		@search_result = Hash.new
		@search_result["id"] = api_record["business_detail"]["id"]
		@search_result["business_name"] = api_record["business_detail"]["business_name"]
		@search_result["website"] = api_record["business_detail"]["website"]
		@search_result["industry"] = api_record["business_detail"]["industry"]

	  	@disavow = Disavow.new
	  	@current_date = Time.now.strftime("%Y-%m-%d")
	end

	def create
		@disavow = Disavow.new(disavow_params)
		if @disavow.save 
			redirect_to root_path
		else
			render "new"
		end
	end

	def destroy
		@disavow = Disavow.find(params[:id])
		if @disavow.destroy
			redirect_to root_path
		else
			redirect_to root_path
		end
	end

	def test
		@domain = "http://www.powerofbowser.com/"
		@our_host = URI.parse(@domain).host
		@info_hash = Hash.new
		@then = Time.now
		page_parser(@domain)
		# raise [@info_hash.keys, @info_hash.keys.size].inspect
		# raise @info_hash.keys.size.inspect
		# raise @info_hash.keys.inspect
		raise @info_hash.inspect
	end

	private 
	def disavow_params
		params.require(:disavow).permit(:api_record_id, :date_cancelled)
	end

	#This method gets records from Brian's API using the API record id
	def get_record_by_id(id) 
		url = URI.escape("http://clientcloud.herokuapp.com/retrieve?key=#{ENV["APPLICATION_KEY"]}&id=#{id}&business_detail")
		response = open(url).read
		return JSON.parse(response)
	end

	#This method gets the title and meta data from a website
	def get_page_info(doc, url)
		website_title_string = doc.xpath('//title').text 
		website_meta_string = doc.css('meta[name="description"]').first['content']

		#The keys of this hash are a webpage url and the value is a subhash. THe subhash has keys that represent either the title or description and the value is the actual title/description text
		@info_hash[url] = {
			title: website_title_string,
			description: website_meta_string
		}
	end

	#This method parses a webpage and looks for links inside the webpage
	def page_parser(parent_url)
		#This removes spaces from the beginning and the end of the url
		parent_url = parent_url.strip

		#This block of code tries to get meta information and rescues if the link is broken
		begin
			doc = Nokogiri::HTML(open(URI.encode(parent_url)))
			get_page_info(doc, parent_url)
		rescue OpenURI::HTTPError
			return
		end

		#A blacklist for illegal characters
		blacklist = ["#"]
		#hrefs will hold valid links that are parsable
		hrefs = doc.css('a[href]').map do |element|
			this_url = element.attributes['href'].value
			#If a link holds a hash, make it nil
			this_url = nil if blacklist.include? this_url
			#If the link is dynamic, make it nil
			this_url = nil if this_url =~ /\?/
			#If the link is a 404 page, make it nil
			this_url = nil if this_url =~ /404/

			if this_url
				#Turning an incorrectly formatted url in to a correct format
				this_host = URI.parse(URI.encode(this_url.strip)).host

				# this url has a host, so compare it with our own and throw it out if it is different
				if this_host
					this_url = nil if this_host.downcase != @our_host.downcase
					
				# else we have a relative url
				else
					# remove leading slashes for relative this_urls
					this_url = this_url.gsub(/^\/+/, "")
					this_url = @domain + this_url
				end
			end

			this_url
		end
		#Getting rid of nil values from hash
		hrefs.compact!
		#Getting rid of duplicate elements from hash
		hrefs.uniq!

		#Deleting already parsed webpages from the hrefs array. 
		hrefs -= @info_hash.keys
		hrefs.each do |this_url|
			#Breaking out of the loop if the time exceeds 25 seconds
			break if Time.now - @then > 25
			begin
				this_doc = Nokogiri::HTML(open(URI.encode(this_url)))
				get_page_info(this_doc, this_url)
			rescue OpenURI::HTTPError
				next
			end
			# page_parser(this_url) unless @info_hash.keys.include? this_url
		end

		return hrefs
	end
end