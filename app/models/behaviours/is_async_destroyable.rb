module IsAsyncDestroyable
  def async_destroy 
    klass = self.class
    worker = "::Destroy#{klass}Worker".constantize
    worker.perform_async(self.id)
  end
end
