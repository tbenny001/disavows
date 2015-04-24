class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def get_business_id
  	require "open-uri"
	business_name = params[:api_record_id].to_s
	url = URI.escape("http://clientcloud.herokuapp.com/search?key=593264690503&q=#{business_name}")
	response = open(url).read
	return JSON.parse(response)
  end

  def get_api_params_by_id
  	require "open-uri"
  	id = params[:id].to_s
	url = URI.escape("http://clientcloud.herokuapp.com/retrieve?key=593264690503&id=#{id}&business_detail")
	response = open(url).read
	api_record = JSON.parse(response)
	return api_record
  end
end
