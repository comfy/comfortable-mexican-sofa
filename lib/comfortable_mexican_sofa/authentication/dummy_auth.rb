module ComfortableMexicanSofa::DummyAuth

  # Will always let you in
  def authenticate
    true
  end

  # The list of sites this authorization is allowed to edit.
  def available_sites
    Cms::Site.all
  end
end
