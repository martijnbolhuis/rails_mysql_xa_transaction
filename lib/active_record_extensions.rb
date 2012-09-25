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

module XaTransaction
  # def xa_transaction_in_progress?
  #   @xa_state != :none
  # end

  def transaction_disabled?
    @transaction_disabled or @xa_state != :none
  end

  def disable_transaction
    @transaction_disabled = true
  end

  def enable_transaction
    @transaction_disabled = false
  end

  def xa_transaction_successful?
    @xa_state == :commit
  end
  
  def begin_xa_transaction id
    @xa_state = :none
    execute "XA START '#{id}'"
    @xa_state = :begin
    
  end

  def end_xa_transaction id
    execute "XA END '#{id}'"
    @xa_state = :end
  end
  
  def prepare_xa_transaction id
    execute "XA PREPARE '#{id}'"
    @xa_state = :prepare  
  end

  def commit_xa_transaction id
    begin
      Rails.logger.info "XATransaction - Before commit. Global ID: #{id} Database: #{@config[:host]} #{@config[:database]}"
      @xa_state = :before_commit
      execute "XA COMMIT '#{id}'"
    rescue
      Rails.logger.warn "XATransaction - Failed commit. Global ID: #{id} Database: #{@config[:host]} #{@config[:database]}"
    else
      @xa_state = :commit
      Rails.logger.info"XATransaction - After commit. Global ID: #{id} Database: #{@config[:host]} #{@config[:database]}"
    end
  end

  def rollback_xa_transaction id
    begin
      end_xa_transaction id if @xa_state == :begin
      if @xa_state == :end
        Rails.logger.info "XATransaction - Before rollback. Global ID: #{id} Database: #{@config[:host]} #{@config[:database]}"
        @xa_state = :before_rollback
        execute "XA ROLLBACK '#{id}'"
      end 
    rescue
      Rails.logger.warn "XATransaction - Rollback failed. Global ID: #{id} Database: #{@config[:host]} #{@config[:database]}"
    else
      @xa_state = :rollback
      Rails.logger.info "XATransaction - After rollback. Global ID: #{id} Database: #{@config[:host]} #{@config[:database]}"
    end
  end

# The following methods override existing methods
  def begin_db_transaction
    original_begin_db_transaction unless transaction_disabled?
  end

  def commit_db_transaction
    original_commit_db_transaction unless transaction_disabled?
  end

  def rollback_db_transaction
    original_rollback_db_transaction unless transaction_disabled?
  end
end



