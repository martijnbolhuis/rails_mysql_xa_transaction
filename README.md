# Distributed transactions in Rails with MySQL

This plugin for Rails provides experimental support for distributed atomic transactions (transaction over multiple database systems) with MySQL.
This is accomplished by using the two-phase commit protocol (2PC) in conjunction with the [MySQL XA statements](http://dev.mysql.com/doc/refman/5.0/en/xa-statements.html)

# Install
Add the git repository to your project's Gemfile and run `bundle install` :
```ruby
gem 'mysql_xa_transaction', :git => 'https://github.com/martijnbolhuis/rails_mysql_xa_transaction.git'
```

# Usage
Set up multiple databases for models in your project. This can be done by using the [connection_ninja plugin](see https://github.com/cherring/connection_ninja for more info).

## Connection ninja configuration

Add connection_ninja to your Gemfile
    gem 'connection_ninja'

    class MyModel < ActiveRecord::Base
      use_connection_ninja(:other_database)
    end

After your normal configuration in database.yml add a new group:

    other_database:
      development:
        adapter: mysql2
        database: database_name
        user: username
        host: 192.168.3.4

      production:
        adapter: mysql2
        database: database_name
        user: username
        host: 192.168.3.4

## Transaction
A transaction can be started as follows:
```ruby
XATransactionCoordinator.XATransaction [KlmTicket, AirFranceTicket] do
  @klm_ticket.save!
  @air_france_ticket.save!
end
```
The XATransaction method receives an optional list of models that are part of the transaction. When this list is not suplied, it will start a transaction over all models in your project (not recommended!). Be sure to use `save!` and *not* `save` within the transaction block. A boolean value will be returned indicating whether the transaction was successful.

# Limitations
Failure of _commit_ or _rollback_ operations are logged to the standard rails logger but recovery is **not** implemented. 