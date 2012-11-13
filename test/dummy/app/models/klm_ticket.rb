class KlmTicket < Ticket
  use_connection_ninja(:external_server)

  validates :flightnumber, format: {with: /KL\s\w\d{2,4}/}
end