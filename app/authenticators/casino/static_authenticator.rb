require 'casino/authenticator'

# The static authenticator is just a simple example.
# Never use this authenticator in a productive environment!
class CASino::StaticAuthenticator < CASino::Authenticator

  # @param [Hash] options
  def initialize(options)
    @users = options[:users] || {}
    @first_name_attribute = options[:first_name_attribute] || :first_name
    @email_attribute = options[:email_attribute] || :email
  end

  def validate(username, password)
    username = :"#{username}"
    if @users.include?(username) && @users[username][:password] == password
      load_user_data(username)
    else
      false
    end
  end

  def load_user_data(username)
    return unless @users.include?(username)

    user = @users[username]
    {
      username: username,
      extra_attributes: user.except(:password)
    }
  end

  def first_name_from_extra_attributes(extra_attributes)
    extra_attributes[@first_name_attribute]
  end

  def email_from_extra_attributes(extra_attributes)
    extra_attributes[@email_attribute]
  end
end
