FactoryGirl.define do
  factory :revision, class: Comfy::Cms::Revision do
    association :record, factory: :page
    data {
      {
        'foo'=> 'bar'
      }.to_yaml.inspect
    }
  end
end
