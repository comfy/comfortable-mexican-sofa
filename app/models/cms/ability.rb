class Cms::Ability
  include CanCan::Ability

  def initialize(user)
    if user
      if user.super_admin?
        can :manage, :all
      else
        can :manage, Cms::Site, {site_users: {user_id: user.id}}
        [Cms::Category, Cms::File, Cms::Layout, Cms::Page, Cms::Snippet].each do |resource|
          can :manage, resource, site: {site_users: {user_id: user.id}}
        end

        # Users can manage themselves
        can [:read, :update], Cms::User, id: user.id
      end
    end
  end
end
