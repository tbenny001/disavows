class Disavow < ActiveRecord::Base
	validates_presence_of(:date_cancelled)
end
