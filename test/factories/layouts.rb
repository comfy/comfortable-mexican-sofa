FactoryGirl.define do
  factory :layout, class: Comfy::Cms::Layout do
    site
    sequence :label do |n|
      "Layout #{n}"
    end
    identifier { label.downcase.gsub(/\s/, '-') }
    content "{{ cms:page:content:rich_text }}"
  end
end
