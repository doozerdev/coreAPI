class User
  include MongoMapper::Document

  #  key :provider, String
  #note, always use uid. This is the ID from facebook, the ID that we want to bind
  #to, if you use id you'll get the MongoDB item ID, which doesn't mean anything
  key :uid, String
  key :email, String
  key :first_name, String
  key :last_name, String
  key :gender, String
  key :link, String
  key :locale, String
  key :timezone, Integer
  key :oauth_token, String
  key :expires_at, Time
  key :session_id, String
  key :role, String

  User.ensure_index ([[:email, 1], [:uid,1]]), :unique => true

  def self.from_token(token)
    graph = Koala::Facebook::API.new(token)
    begin
      profile = graph.get_object("me")
      user = User.first_or_create(:uid=>profile['id'])
      user.uid = profile['id']
      user.email = profile['email']
      user.first_name = profile['first_name']
      user.last_name = profile['last_name']
      user.gender = profile['gender']
      user.link = profile['link']
      user.locale = profile['locale']
      user.timezone = profile['timezone']
      user.oauth_token = token
      user.expires_at = DateTime.now + 24.hours
      user.session_id = SecureRandom.hex(32)
      user.save!
      user
    rescue
      nil
    end
  end

  def as_json(options = { })
    h = super(options)
    h.delete('oauth_token')
    h.delete('id')
    h.delete('session_id')
    h.delete('first_name')
    h.delete('last_name')
    h
  end

end
