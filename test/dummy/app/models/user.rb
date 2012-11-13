class User < ActiveRecord::Base
  attr_accessible :first_name, :last_name, :username
  has_many :klm_tickets
  has_many :air_france_tickets
end
