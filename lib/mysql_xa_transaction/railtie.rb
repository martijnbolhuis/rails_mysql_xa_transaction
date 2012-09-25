require 'rails'
class MysqlXARailtie < Rails::Railtie
  initializer "mysql_xa_railtie.configure_rails_initialization" do
    config.xa_logger = Logger.new(STDOUT)
    require 'active_record_extensions.rb'
    ActiveRecord::ConnectionAdapters::Mysql2Adapter.class_eval do
      alias_method :original_begin_db_transaction, :begin_db_transaction
      alias_method :original_commit_db_transaction, :commit_db_transaction
      alias_method :original_rollback_db_transaction, :rollback_db_transaction
      include XaTransaction
    end
  end
end