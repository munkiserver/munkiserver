require 'spec_helper'
require 'sidekiq/testing'
Sidekiq::Testing.fake!

describe DeleteComputerWorker do
  context "when an existing computer is queued for deletion" do
    it "should delete the computer" do
      computer = FactoryGirl.create(:computer)
      computer_id = computer.id
      DeleteComputerWorker.perform_async(computer.id)
      DeleteComputerWorker.drain
      Computer.find_by_id(computer_id).should == nil
    end
  end

  context "when an nonexistant computer is passed" do
    it "should be a noop" do
      not_a_computer_id = -1
      DeleteComputerWorker.perform_async(not_a_computer_id)
      expect {
        DeleteComputerWorker.drain
      }.to_not raise_error
    end
  end
end
