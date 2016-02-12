FactoryGirl.define do
  factory :page, class: Comfy::Cms::Page do
    site
    layout
    label { Faker::Lorem.words(3).join(' ') }
    full_path { label.downcase.gsub(/\s/, '-' ) }
  end
end
