class CASino::UsersMailer < ActionMailer::Base
  layout 'mailer'

  def reset_password_email(authenticator_user, reset_password_token)
    user = CASino::User.from_authenticator_user(authenticator_user)

    return if user.email.blank?

    @user = user
    @link = change_password_url(token: reset_password_token.token)

    mail(
      from: CASino.config.passwords[:forgot_email_from],
      to: "#{user.first_name} <#{user.email}>",
      subject: I18n.t('forgot_password.email_subject')
    )
  end
end
