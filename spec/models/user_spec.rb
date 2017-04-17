require 'spec_helper'

describe User, :type => :model do
  describe "factory" do
    it 'should be valid' do
      expect(FactoryGirl.build(:user)).to be_valid
    end
  end
end