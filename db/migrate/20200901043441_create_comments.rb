class CreateComments < ActiveRecord::Migration[6.0]
  def change
  	create_table :comments do |t|
        t.text :message
        t.text :post

        t.timestamps
	end
  end
end
