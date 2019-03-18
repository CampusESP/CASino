require 'casino/authenticator'

# The static authenticator is just a simple example.
# Never use this authenticator in a productive environment!
class CASino::StaticAuthenticator < CASino::Authenticator

  # @param [Hash] options
  def initialize(options)
    @users = options[:users] || {}
    @first_name_attribute = options[:first_name_attribute] || :first_name
    @email_attribute = options[:email_attribute] || :email
    @login_attribute = options[:login_attribute] || :username
  end

  def validate(username, password)
    username = :"#{username}"
    if @users.include?(username) && @users[username][:password] == password
      load_user_data(username)
    else
      false
    end
  end

  def update_password(username, password)
    CASino.logger.debug "Password for #{username} should be changed to #{password}."
    true
  end

  def load_user_data(username, _login = true)
    return unless @users.include?(username)

    user = @users[username]
    {
      username: username,
      extra_attributes: user.except(:password)
    }
  end

  def first_name(attributes)
    attributes[@first_name_attribute]
  end

  def email(attributes)
    attributes[@email_attribute]
  end

  def login(attributes)
    attributes[@login_attribute]
  end
end
