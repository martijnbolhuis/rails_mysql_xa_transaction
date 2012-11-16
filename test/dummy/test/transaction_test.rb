# ruby -I"lib:test" test/unit/transaction_test.rb
require 'test_helper'
require 'rake'
Rake::Task.clear
Dummy::Application.load_tasks 

class TransactionTest < ActiveSupport::TestCase

  # Executed before each test
  def setup
    [AirFranceTicket, KlmTicket, User].each {|klass| klass.connection.send(:disable_transaction)}
    @klm_ticket = create_klm_ticket
    @air_france_ticket = create_air_france_ticket
  end

  test "Normal XA transaction should be successful" do
    start_and_check_mysql
    @result = XATransactionCoordinator.XATransaction [KlmTicket, AirFranceTicket] do
      @klm_ticket.save!
      @air_france_ticket.save!
    end
    # The result should be true if the transaction is successful
    assert_successful_transaction
  end

  test "MySQL is shutdown before transaction" do
    stop_and_check_mysql
    @result = XATransactionCoordinator.XATransaction [KlmTicket, AirFranceTicket] do
      @klm_ticket.save!
      @air_france_ticket.save!
    end
    start_and_check_mysql
    # The followin command will reopen the database connection
    ActiveRecord::Base.verify_active_connections!
    assert_failed_transaction
  end

  test "MySQL is shutdown during the transaction" do
    start_and_check_mysql

      @result = XATransactionCoordinator.XATransaction [KlmTicket, AirFranceTicket] do
        @klm_ticket.save!
        stop_and_check_mysql
        @air_france_ticket.save!
      end

    start_and_check_mysql
    # The followin command will reopen the database connection
    ActiveRecord::Base.verify_active_connections!
    # debugger
    assert_failed_transaction
  end

  test "Both tickets should not be saved if a validation fails" do
    start_and_check_mysql
    # Create a ticket with an invalid flightnumber
    @klm_ticket = create_klm_ticket flightnumber: 'ABC 3674'

    result = XATransactionCoordinator.XATransaction [KlmTicket, AirFranceTicket] do
      @klm_ticket.save!
      @air_france_ticket.save!
    end

    assert_failed_transaction

  end

  # =====

  test "MySQL is killed before transaction" do
    crash_and_check_mysql
    @result = XATransactionCoordinator.XATransaction [KlmTicket, AirFranceTicket] do
      @klm_ticket.save!
      @air_france_ticket.save!
    end
    start_and_check_mysql
    # The followin command will reopen the database connection
    ActiveRecord::Base.verify_active_connections!
    assert_failed_transaction
  end

  test "MySQL is killed during the transaction" do
    start_and_check_mysql

      @result = XATransactionCoordinator.XATransaction [KlmTicket, AirFranceTicket] do
        @klm_ticket.save!
        crash_and_check_mysql
        @air_france_ticket.save!
      end

    start_and_check_mysql
    # The followin command will reopen the database connection
    ActiveRecord::Base.verify_active_connections!
    # debugger
    assert_failed_transaction
  end

end