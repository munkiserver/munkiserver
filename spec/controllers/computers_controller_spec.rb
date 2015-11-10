require 'spec_helper'
require 'sidekiq/testing'
Sidekiq::Testing.fake!

describe ComputersController do
  describe "update_multiple" do
    computers = FactoryGirl.create_list(:computer, 10)
    put :update_multiple, :selected_records => computers.map(&:id)
    expect_any_instance_of(Computer).to receive(:async_destroy)
  end
end
