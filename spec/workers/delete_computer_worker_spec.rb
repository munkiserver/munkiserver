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
end
