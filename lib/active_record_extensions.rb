module ActiveRecord
  module ConnectionAdapters
    module DatabaseStatements
       def xa_transaction_in_progress
        raise NotImplementedError, "xa_transaction_in_progress is an abstract method"
       end

       def begin_xa_transaction id
        raise NotImplementedError, "begin_xa_transaction is an abstract method"
       end

       def end_xa_transaction id
        raise NotImplementedError, "end_xa_transaction is an abstract method"
       end

       def prepare_xa_transaction id
         raise NotImplementedError, "prepare_xa_transaction is an abstract method"
       end

       def commit_xa_transaction id
         raise NotImplementedError, "commit_xa_transaction is an abstract method"
       end

       def rollback_xa_transaction id
         raise NotImplementedError, "rollback_xa_transaction is an abstract method"
       end
    end
  end
end

module ActiveRecord
  module ConnectionAdapters    
    class AbstractMysqlAdapter < AbstractAdapter
      def xa_transaction_in_progress
        @xa_state.present? && @xa_state != :none
      end

      def begin_db_transaction
        # super unless xa_transaction_in_progress
        raise "blablba"
      end

      def commit_db_transaction
        super unless xa_transaction_in_progress
      end

      def begin_xa_transaction id
        @xa_state = :none
        begin
          execute "XA START '#{id}'"
        rescue
          raise "Error"
        else
          @xa_state = :begin
        end
      end

      def end_xa_transaction id
        begin
          execute "XA END '#{id}'"
        rescue
          raise "Error"
        else
          @xa_state = :end
        end
      end
      
      def prepare_xa_transaction id
        begin
          execute "XA PREPARE '#{id}'"
        rescue
          raise "Error"
        else
          @xa_state = :prepare
        end     
      end

      def commit_xa_transaction id
        begin
          execute "XA COMMIT '#{id}'"
        rescue
          raise "Atomicity of XA transaction violated"
        else
          @xa_state = :none
        end
      end

      def rollback_xa_transaction id
        begin
          end_xa_transaction id if @xa_state == :begin
          execute "XA ROLLBACK '#{id}'" if @xa_state == :end
        rescue
          raise "Error"
        else
          @xa_state = :none
        end
      end


    end
  end
end