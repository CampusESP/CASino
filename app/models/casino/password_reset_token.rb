class CASino::PasswordResetToken < CASino::ApplicationRecord
  scope :active, -> { where('created_at >= ?', CASino.config.passwords[:forgot_token_lifetime].seconds.ago) }
  scope :inactive, -> { where('created_at < ?', CASino.config.passwords[:forgot_token_lifetime].seconds.ago) }

  def self.for(authenticator:, username:, retry_interval:)
    password_reset_token = find_or_initialize_by(authenticator: authenticator, username: username)

    return if password_reset_token.persisted? && password_reset_token.updated_at > retry_interval.ago

    password_reset_token.token = SecureRandom.urlsafe_base64(30)
    password_reset_token.save!
    password_reset_token
  rescue ActiveRecord::RecordNotUnique
    nil
  end

  def self.cleanup
    inactive.destroy_all
  end
end
