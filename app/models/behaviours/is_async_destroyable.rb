module IsAsyncDestroyable
  def async_destroy
    update_attribute(:deleted_at, Time.now)
    klass = self.class
    worker = "::Destroy#{klass}Worker".constantize
    worker.perform_async(id)
  end
end
