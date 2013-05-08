class Cms::Ability
  include CanCan::Ability

  def initialize(user)
    if user
      if user.super_admin?
        can :manage, :all
      else
        can :manage, Cms::Site, {site_users: {user_id: user.id}}
        # Nested resources too?
      end
    end
  end
end
