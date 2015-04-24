class DeleteColumns < ActiveRecord::Migration
  def change
  	remove_column :disavows, :business_name
  	remove_column :disavows, :website
  	remove_column :disavows, :industry
  	add_column :disavows, :api_record_id, :integer
  end
end
