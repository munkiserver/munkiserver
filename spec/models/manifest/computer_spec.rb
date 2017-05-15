require "spec_helper"

describe Computer, type: :model do
  it "Factory should be valid" do
    expect(FactoryGirl.build(:computer)).to be_valid
  end

  it "Factory list should be valid" do
    expect do
      FactoryGirl.create_list(:computer, 20)
    end.to_not raise_error
  end
end
