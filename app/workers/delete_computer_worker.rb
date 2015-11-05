class DeleteComputerWorker
  include Sidekiq::Worker

  def perform(id)
    # find_by_id returns `nil` if not found
    computer = Computer.find_by_id(id)
    computer.destroy if computer
  end
end
