class CreateUsers < ActiveRecord::Migration
  
  def change
    create_table :users, :force => true do |t|
	    t.timestamps
	    t.string :username
  	end
  end
  
end