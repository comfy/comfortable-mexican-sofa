require_relative '../test_helper'

class CmsAbilityTest < ActiveSupport::TestCase

  def test_super_admins_can_manage_sites
    ability = Cms::Ability.new cms_users(:admin)

    assert ability.can? :manage, cms_sites(:default)
  end

  def test_normal_users_cannot_manage_other_sites
    ability = Cms::Ability.new cms_users(:normal)

    refute ability.can? :manage, cms_sites(:default)
  end

  def test_normal_users_cannot_manage_other_categories
    ability = Cms::Ability.new cms_users(:normal)

    refute ability.can? :manage, cms_categories(:default)
  end

  def test_normal_users_can_manage_categories
    ability = Cms::Ability.new cms_users(:normal)

    assert ability.can? :manage, cms_categories(:users_site_category)
  end

end
