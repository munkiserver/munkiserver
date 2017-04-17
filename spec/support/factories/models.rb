FactoryGirl.define do
  factory :computer do
    sequence(:name) { |n| "#{Faker::Book.title} #{n}" }
    mac_address  { Faker::Internet.mac_address }
    environment
    unit
  end

  factory :environment do
    sequence(:name) {|n| "Environment #{n}" }
    description "Factory-made environment"
  end

  factory :unit do
    sequence(:name) { |n| "#{Faker::Book.title} #{n}" }
    description "Factory-made unit"
  end

  factory :package do
    unit
    environment
    installer_item_location { "foo" }
    version { "1.0" }
    package_branch
  end

  factory :package_branch do
    unit
    package_category
    sequence(:name) {|n| "package_branch_#{n}" }
    sequence(:display_name) {|n| "Package Branch #{n}" }
  end

  factory :package_category do
    sequence(:name) {|n| "Package Category #{n}" }
    description "Description"
  end

  factory :api_key do
    user
  end

  factory :user do
    sequence(:username) {|n| "user#{n}" }
    sequence(:email)    {|n| "user#{n}@munkiserver.com" }
    password { "abcd1234" }
    password_confirmation { "abcd1234" }
    salt { "salt" }
  end

end
