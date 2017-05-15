require "spec_helper"

describe ApiKey, type: :model do
  describe "initializes a random API Key" do
    let(:api_key) { ApiKey.new }

    it "should generate a string" do
      expect(api_key.key).to be_a String
    end

    it "should not be blank" do
      expect(api_key.key).to_not be_blank
    end

    it "should be longer than 10 characters" do
      expect(api_key.key.length).to be > 16
    end
  end

  describe "validations" do
    subject { FactoryGirl.build(:api_key) }

    it "factory should be valid" do
      expect(subject).to be_valid
    end

    it "should be invalid without an api_key" do
      subject.key = nil
      expect(subject).to_not be_valid
    end

    it "should be invalid without an user" do
      subject.user = nil
      expect(subject).to_not be_valid
    end
  end
end
