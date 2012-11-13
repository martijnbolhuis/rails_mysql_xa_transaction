class CreateTickets < ActiveRecord::Migration
  def change
    create_table :tickets do |t|
      t.string :departure
      t.string :destination
      t.decimal :price, :precision => 8, :scale => 2
      t.string :flightnumber
      t.integer :user_id
      t.datetime :departure_time
      t.datetime :arrival_time

      t.timestamps
    end
  end
end
