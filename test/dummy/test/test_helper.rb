ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase

  # Time to suspend execution after restarting mysql
  WAITING_TIME = 5

  def create_klm_ticket options={}
    params = {departure: "EHAM", destination: "EGKK", price: 100, flightnumber: "KL 5555", user_id: nil, departure_time: "2012-08-30 15:33:00", arrival_time: "2012-08-30 15:33:00"}
    KlmTicket.new params.merge options
  end

  def create_air_france_ticket options={}
    params = {departure: "EHAM", destination: "EGKK", price: 100, flightnumber: "AF 1234", user_id: nil, departure_time: "2012-08-30 15:33:00", arrival_time: "2012-08-30 15:33:00"}
    AirFranceTicket.new params.merge options
  end

  def mysql_server_running?
    pid = `ps -ef | grep mysql | awk '{if ($1 ~ /mysql/) print $2}'`
    pid.present?
  end

  def start_and_check_mysql
    require 'rake'
    Rake::Task.clear # necessary to avoid tasks being loaded several times in dev mode
    Dummy::Application.load_tasks
    Rake::Task["mysql:start"].invoke
    sleep WAITING_TIME
    assert mysql_server_running?, "MySQL server is not running while it should!"
  end

  def stop_and_check_mysql
    Rake::Task["mysql:stop"].invoke
    sleep WAITING_TIME
    assert !mysql_server_running?, "MySQL server is running while it should not!"
  end

  def crash_and_check_mysql
    Rake::Task["mysql:crash"].invoke
    sleep WAITING_TIME
    assert !mysql_server_running?, "MySQL server is running while it should not!"
  end

  def assert_failed_transaction
    assert !@result, 'The TM should indicate that the transaction has failed'
    # assert @klm_ticket.new_record? and @air_france_ticket.new_record?

    assert KlmTicket.last != @klm_ticket, 'Last KLM ticket should NOT match the created ticket'
    assert AirFranceTicket.last != @air_france_ticket, 'Last KLM ticket should NOT match the created ticket'

  end

  def assert_successful_transaction
    assert @result, 'The TM should indicate that the transaction is successful'
    assert KlmTicket.last == @klm_ticket, 'Last KLM ticket should match the created ticket'
    assert AirFranceTicket.last == @air_france_ticket, 'Last KLM ticket should match the created ticket'
  end



end
