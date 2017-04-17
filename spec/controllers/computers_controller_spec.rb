require "spec_helper"
require "sidekiq/testing"
Sidekiq::Testing.fake!

describe ComputersController, :type => :controller do
  before do
    user = double(:user, :id => 1, :name => "root", :is_root? => true)
    allow(user).to receive(:all_permissions).and_return([])
    allow(controller).to receive(:current_user).and_return(user)
  end

  it "should work when you update_multiple" do
    unit = FactoryGirl.create(:unit)
    computers = FactoryGirl.create_list(:computer, 10, :unit => unit)
    computer_ids = computers.map(&:id)
    expect {
      put :update_multiple, :unit_shortname => unit.shortname, :selected_records => computer_ids, :commit => "Delete"
    }.to change(DestroyComputerWorker.jobs, :size).by(computer_ids.length)
    expect(response).to redirect_to computers_path
    expect(Computer.unscoped.where("deleted_at IS NOT NULL").find(computer_ids).length).to eq(computer_ids.length)
  end
end
