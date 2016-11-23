class BaseWorker
  include Sidekiq::Worker

  private

  def with_connection(&block)
    ActiveRecord::Base.connection_pool.with_connection do
      yield block
    end
  ensure
    ActiveRecord::Base.clear_active_connections!
    ActiveRecord::Base.connection.close
  end
end
