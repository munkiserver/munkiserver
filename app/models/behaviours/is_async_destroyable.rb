module IsAsyncDestroyable
  def async_destroy
    self.update_attribute(:deleted_at, Time.now)
    klass = self.class
    worker = "::Destroy#{klass}Worker".constantize
    worker.perform_async(self.id)
  end
end
