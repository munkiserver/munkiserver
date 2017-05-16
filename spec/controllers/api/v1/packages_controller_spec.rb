require "spec_helper"

describe Api::V1::PackagesController, type: :controller do
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
    let(:production) { Environment.create(name: "Production") }
    let(:package_branch) { FactoryGirl.create(:package_branch, unit: unit) }
    let!(:package_branch2) { FactoryGirl.create(:package_branch, unit: unit) }
    let!(:staging_package) { FactoryGirl.create(:package, package_branch: package_branch, unit: unit, environment: staging, version: "2.0") }
    let!(:production_package) { FactoryGirl.create(:package, package_branch: package_branch, unit: unit, environment: production, version: "1.0") }

    # Response objects
    it "should return valid result" do
      get :index, unit_shortname: unit.shortname, format: :json

      last_package_branch = response_as_hash.last["package_branch"]
      last_package_branch_packages = last_package_branch["packages"]

      expect(response_as_hash).to be_a Array
      expect(response_as_hash.size).to eq 2

      expect(response_as_hash.first["package_branch"]).to be_a Hash

      expect(last_package_branch["name"]).to eq package_branch.name
      expect(last_package_branch["display"]).to eq package_branch.display_name
      expect(last_package_branch["category"]).to eq package_branch.package_category.name

      expect(last_package_branch_packages).to be_a Array
      expect(last_package_branch_packages.size).to eq 2
      expect(last_package_branch_packages).to include("version" => production_package.version, "environment" => "production")
      expect(last_package_branch_packages).to include("version" => staging_package.version, "environment" => "staging")
    end
  end

  describe "when getting details on individual package" do
    let(:package_branch) { FactoryGirl.create(:package_branch, unit: unit) }
    let!(:package) { FactoryGirl.create(:package, package_branch: package_branch, unit: unit, environment: staging, version: "2.0") }

    it "should show version exists" do
      get :show, unit_shortname: unit.shortname, package_branch: package_branch.name, version: "2.0", format: :json

      expect(response_as_hash).to be_a Hash
      expect(response_as_hash["exists"]).to eq true
    end

    it "should show version details" do
      get :show, unit_shortname: unit.shortname, package_branch: package_branch.name, version: "2.0", format: :json

      expect(response_as_hash["version"]).to eq "2.0"
      expect(response_as_hash["environment"]).to eq "staging"
    end

    it "should conform version query to match expected version number format" do
      expect(Package).to receive(:find_where_params).with(hash_including("version" => "3_0"))

      get :show, unit_shortname: unit.shortname, package_branch: package_branch.name, version: "3 0", format: :json
    end

    it "should show version doesn't exist" do
      get :show, unit_shortname: unit.shortname, package_branch: package_branch.name, version: "1.0", format: :json

      expect(response_as_hash).to be_a Hash
      expect(response_as_hash["exists"]).to eq false
      expect(response_as_hash["environment"]).to eq nil
      expect(response_as_hash["version"]).to eq nil
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
        post :create, unit_shortname: unit.shortname, package_file: package_file, pkginfo_file: pkginfo_file, format: :json

        expect(response_as_hash).to be_a Hash
        expect(response_as_hash["type"]).to eq "success"
        expect(response_as_hash).to include "message"
        expect(response_as_hash).to include "url"
        expect(response_as_hash).to include "edit_url"
        expect(response_as_hash["url"]).to include "http://test.host/"
      end
    end

    describe "failure" do
      before do
        allow_any_instance_of(ProcessPackageUpload).to receive(:process).and_return(false)
        allow_any_instance_of(ProcessPackageUpload).to receive(:processed?).and_return(false)
        allow_any_instance_of(ProcessPackageUpload).to receive(:error_message).and_return("we're stubbed")
      end

      it "should allow you to upload a package" do
        post :create, unit_shortname: unit.shortname, package_file: package_file, pkginfo_file: pkginfo_file, format: :json

        expect(response_as_hash).to be_a Hash
        expect(response_as_hash["type"]).to eq "failure"

        expect(response_as_hash).to include "message"
        expect(response_as_hash["message"]).to include "we're stubbed"

        expect(response_as_hash).to_not include "url"
      end
    end
  end
end
