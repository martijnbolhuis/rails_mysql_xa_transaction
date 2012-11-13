class AirFranceTicket < Ticket
  validates :flightnumber, format: {with: /AF\s\w\d{2,4}/}

  
end