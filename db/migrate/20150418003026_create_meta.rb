class CreateMeta < ActiveRecord::Migration
  def change
    create_table :meta do |t|
      t.string :webpage
      t.integer :parent_id
      t.string :meta_tags
      t.string :title_tags

      t.timestamps null: false
    end
  end
end
