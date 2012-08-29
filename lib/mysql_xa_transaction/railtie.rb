require 'rails'
class MysqlXARailtie < Rails::Railtie
  initializer "mysql_xa_railtie.configure_rails_initialization" do
    ActiveRecord::ConnectionAdapters::Mysql2Adapter.class_eval do
      def begin_db_transaction
      end
   
      def commit_db_transaction
      end
    end
  end
end