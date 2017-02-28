require 'spec_helper'

describe Api::V1::PackagesController, :type => :controller do
  before do
    allow(user).to receive(:all_permissions).and_return([])
    allow(controller).to receive(:current_user).and_return(user)
  end

  let(:user) { double(:user, :id => 1, :name => 'root', :is_root? => true) }
  let!(:staging) { Environment.create name: "Staging"}
  let(:unit) { FactoryGirl.create(:unit) }
  let(:package_file) { double('package.dmg') }
  let(:pkginfo_file) { double('package.plist') }

  describe "success" do
    let(:package) { FactoryGirl.build_stubbed :package }
    before do
      allow_any_instance_of(ProcessPackageUpload).to receive(:process).and_return(true)
      allow_any_instance_of(ProcessPackageUpload).to receive(:processed?).and_return(true)
      allow_any_instance_of(ProcessPackageUpload).to receive(:package).and_return(package)
    end

    it "should allow you to upload a package" do
      post :create, :unit_shortname => unit.shortname, :package_file => package_file, :pkginfo_file => pkginfo_file, format: :json

      parsed_response = JSON.parse(response.body)

      expect(parsed_response).to be_a Hash
      expect(parsed_response["type"]).to eq "success"
      expect(parsed_response).to include "message"
      expect(parsed_response).to include "url"
      expect(parsed_response).to include "edit_url"
      expect(parsed_response["url"]).to include "http://test.host/"
    end
  end

  describe "failure" do
    before do
      allow_any_instance_of(ProcessPackageUpload).to receive(:process).and_return(false)
      allow_any_instance_of(ProcessPackageUpload).to receive(:processed?).and_return(false)
      allow_any_instance_of(ProcessPackageUpload).to receive(:error_message).and_return("we're stubbed")
    end

    it "should allow you to upload a package" do
      post :create, :unit_shortname => unit.shortname, :package_file => package_file, :pkginfo_file => pkginfo_file, format: :json

      parsed_response = JSON.parse(response.body)

      expect(parsed_response).to be_a Hash
      expect(parsed_response["type"]).to eq "failure"

      expect(parsed_response).to include "message"
      expect(parsed_response["message"]).to include "we're stubbed"

      expect(parsed_response).to_not include "url"
    end
  end

end
