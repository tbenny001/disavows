class AddBusinessNameToDisavows < ActiveRecord::Migration
  def change
  	add_column :disavows, :business_name, :string
  	add_column :disavows, :website, :string
  	add_column :disavows, :industry, :string
  	add_column :disavows, :date_cancelled, :datetime
  end
end

