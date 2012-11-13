class Ticket < ActiveRecord::Base
  attr_accessible :arrival_time, :departure, :departure_time, :destination, :flightnumber, :price, :user_id, :airline
  belongs_to :user

  def airline= code
    @airline = code
  end

  def airline
    @airline    
  end
end
