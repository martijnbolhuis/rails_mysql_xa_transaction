# require 'mysql_xa_transaction/railtie.rb'
module MysqlXaTransaction
  
  class XATransaction
    def initialize model_list=[]
      generate_id
      get_db_connections model_list
    end

    def start &block
      begin
        connection_list_do :begin_xa_transaction
        yield
        connection_list_do :end_xa_transaction
        connection_list_do :prepare_xa_transaction
      rescue
        connection_list_do :rollback_xa_transaction
      else
        connection_list_do :commit_xa_transaction
      end
    end
    

    protected
      def generate_id
        @id = (0...8).map{65.+(rand(25)).chr}.join
      end

      def get_db_connections model_list
        @connection_list = []
        model_list.each {|m| @connection_list << m.connection unless @connection_list.include?(m.connection)}
        @connection_list
      end

      def connection_list_do method_symbol
        @connection_list.each {|c| c.send(method_symbol, @id)}
      end
  end
end
