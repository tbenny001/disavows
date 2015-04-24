class CreateDisavows < ActiveRecord::Migration
  def change
    create_table :disavows do |t|

      t.timestamps null: false
    end
  end
end
