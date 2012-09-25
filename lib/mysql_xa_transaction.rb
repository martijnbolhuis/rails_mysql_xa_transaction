if defined?(::Rails::Railtie)
  require 'mysql_xa_transaction/railtie.rb'
end

module XATransactionCoordinator
  def self.XATransaction model_list=[], &block
    t = XATransaction.new model_list
    t.start {yield}  
  end

  class XATransaction
    def initialize model_list=[]
      generate_id

      # Get all models in the project if no models names are supplied
      model_list = get_project_models if model_list.empty?
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
      connection_list_check
    end

    protected

      def get_project_models
        ActiveRecord::Base.connection.tables.collect{|t| eval(t.underscore.singularize.camelize) unless t == "schema_migrations"}.compact
      end

      def generate_id
        @id = (0...8).map{65.+(rand(25)).chr}.join
      end

      def get_db_connections model_list
        @connection_list = []
        model_list.each {|m| @connection_list << m.connection if m.connection.respond_to?(:begin_xa_transaction) unless @connection_list.include?(m.connection)}
        @connection_list
      end

      def connection_list_do method_symbol
        @connection_list.each {|c| c.send(method_symbol, @id)}
      end

      def connection_list_check method_symbol=:xa_transaction_successful?
        @connection_list.map{|c| c.send(method_symbol)}.select {|b| !b}.empty?
      end
  end
end
