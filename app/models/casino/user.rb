
class CASino::User < CASino::ApplicationRecord
  include CASino::AuthenticationProcessor

  serialize :extra_attributes, Hash

  has_many :ticket_granting_tickets
  has_many :two_factor_authenticators
  has_many :login_attempts

  def self.from_authenticator_user(authenticator_user)
    new(
      authenticator: authenticator_user[:authenticator],
      username: authenticator_user[:user_data][:username],
      extra_attributes: authenticator_user[:user_data][:extra_attributes]
    )
  end

  def active_two_factor_authenticator
    self.two_factor_authenticators.where(active: true).first
  end

  def first_name
    authenticator_service.first_name_from_extra_attributes(extra_attributes)
  end

  def email
    authenticator_service.email_from_extra_attributes(extra_attributes)
  end

  private

  def authenticator_service
    @authenticator_service ||= authenticators[authenticator]
  end
end
