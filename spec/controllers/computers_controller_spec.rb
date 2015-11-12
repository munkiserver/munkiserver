require 'spec_helper'
require 'sidekiq/testing'
Sidekiq::Testing.fake!

describe ComputersController, :type => :controller do
  before do
    allow(controller).to receive_messages(:current_user => double(:user, :id => 1))
  end

  it "should work when you update_multiple" do
    
    unit = FactoryGirl.create(:unit)
    computers = FactoryGirl.create_list(:computer, 10, :unit => unit)
    computer_ids = computers.map(&:id)
    put :update_multiple, :unit_shortname => unit.shortname, :selected_records => computer_ids, :commit => 'Delete'
    expect(response).to redirect_to computers_path
    expect(Computer.count).to eq(0)
  end
end
