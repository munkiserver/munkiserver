require "spec_helper"

describe Api::V1::PackagesController, :type => :controller, focus: true do
  before do
    # Stub Permissions
    allow(user).to receive(:all_permissions).and_return([])
    allow(controller).to receive(:current_user).and_return(user)
  end

  let(:user) { double(:user, id: 1, name: "root", is_root?: true) }
  let!(:staging) { Environment.create name: "Staging" }
  let(:unit) { FactoryGirl.create(:unit) }
  let(:package_file) { double("package.dmg") }
  let(:pkginfo_file) { double("package.plist") }

  let(:response_as_hash) { JSON.parse(response.body) }

  describe "when package listing" do
    let(:unit) { create(:unit) }
    let(:production) { Environment.create(name: "Production") }
    let(:package_branch) { create(:package_branch, unit: unit) }
    let(:staging_package) { create(:package, package_branch: package_branch, unit: unit, environment: staging, version: "1.0") }
    let(:production_package) { create(:package, package_branch: package_branch, unit: unit, environment: production, version: "2.0") }

    # Response objects
    it "should return valid result" do
      response_as_hash = JSON.parse(response.body)
      first_package_branch = response_as_hash.first["package_branch"]
      first_package_branch_verisons = first_package_branch["versions"]

      expect(response_as_hash).to be_a Array
      expect(response_as_hash.size).to eq 1

      expect(response_as_hash.first["package_branch"]).to be_a Hash

      expect(first_package_branch["name"]).to eq package_branch.name
      expect(first_package_branch["display"]).to eq package_branch.display_name
      expect(first_package_branch["category"]).to eq package_branch.package_category.name.lcase

      expect(first_package_branch["versions"]).to be_a Hash
      expect(first_package_branch_verisons["summary"]).to eq [staging_package.version, production_package.version]
      expect(first_package_branch_verisons["details"]["staging"]).to eq [staging_package.version]
      expect(first_package_branch_verisons["details"]["production"]).to eq [production_package.version]
    end
  end

  describe "when create package" do
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
end
