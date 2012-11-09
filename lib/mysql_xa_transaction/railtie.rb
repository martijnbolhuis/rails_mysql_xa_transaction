require 'rails'
require 'active_record/connection_adapters/mysql2_adapter'
require 'active_record/connection_adapters/abstract_mysql_adapter'
require 'active_record_extensions.rb'

class MysqlXARailtie < Rails::Railtie
  initializer "mysql_xa_railtie.configure_rails_initialization" do
    config.xa_logger = Logger.new(STDOUT)
    ActiveRecord::ConnectionAdapters::Mysql2Adapter.class_eval do
      alias_method :original_begin_db_transaction, :begin_db_transaction
      alias_method :original_commit_db_transaction, :commit_db_transaction
      alias_method :original_rollback_db_transaction, :rollback_db_transaction
      alias_method :original_create_savepoint, :create_savepoint
      alias_method :original_release_savepoint, :release_savepoint
      alias_method :original_rollback_to_savepoint, :rollback_to_savepoint
      include XaTransaction
    end
  end
end