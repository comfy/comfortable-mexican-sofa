FactoryGirl.define do
  factory :site, class: Comfy::Cms::Site do
    label { Faker::Lorem.words(3).join(' ') }
    identifier { label.downcase.gsub(/\s/, '-') }
    hostname { Faker::Internet.domain_name }
  end
end
