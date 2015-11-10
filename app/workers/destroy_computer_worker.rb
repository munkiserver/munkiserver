class DestroyComputerWorker < BaseWorker
  def perform(id)
		with_connection do
			# find_by_id returns `nil` if not found
			computer = Computer.find_by_id(id)
			computer.destroy if computer
		end
  end
end
