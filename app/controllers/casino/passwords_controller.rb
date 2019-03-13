class CASino::PasswordsController < CASino::ApplicationController
  include CASino::SessionsHelper
  include CASino::AuthenticationProcessor

  helper_method :user, :password_related_info

  def forgot
    redirect_to(root_path) && return unless forgot_password_allowed?
    return unless request.post? && login

    CASino::UsersMailer.reset_password_email(authenticator_user, new_password_reset_token).deliver_later if authenticator_user && new_password_reset_token

    flash[:notice] = I18n.t('forgot_password.email_sent')
    redirect_to login_path
  end

  def change
    redirect_to(root_path) && return unless change_password_allowed? && (forgot_password_allowed? || signed_in?)
    redirect_to(login_path) && return unless signed_in? || valid_password_reset_token?

    return unless request.post? && valid_new_password?

    change_password
    existing_password_reset_token.destroy! unless signed_in?

    redirect_to root_path
  end

  private

  def login
    @login ||= if params[:login].present?
                 params[:login]
               else
                 flash.now[:error] = I18n.t('forgot_password.missing_user')
                 nil
               end
  end

  def username
    @username ||= existing_password_reset_token.username if existing_password_reset_token.present?
  end

  def user
    @user ||= signed_in? ? current_user : CASino::User.from_authenticator_user(authenticator_user)
  end

  def authenticator_user
    @authenticator_user ||= find(login || username, existing_password_reset_token.blank?)
  end

  def new_password_reset_token
    @new_password_reset_token ||= CASino::PasswordResetToken.for(
      authenticator: user.authenticator,
      username: user.username,
      retry_interval: CASino.config.passwords[:forgot_retry_interval].seconds
    )
  end

  def valid_password_reset_token?
    @valid_password_reset_token ||= if existing_password_reset_token
                                      true
                                    else
                                      flash.now[:error] = I18n.t('change_password.invalid_token')
                                      false
                                    end
  end

  def existing_password_reset_token
    return @existing_password_reset_token if defined?(@existing_password_reset_token)

    @existing_password_reset_token = CASino::PasswordResetToken.active.find_by(token: params[:token]) if params[:token]
  end

  def change_password
    request_info = signed_in? ? current_user : existing_password_reset_token
    if update_password(request_info.authenticator, request_info.username, new_password)
      flash[:notice] = I18n.t('change_password.password_changed')
    else
      flash[:error] = I18n.t('change_password.password_not_changed')
    end
  end

  def valid_new_password?
    @valid_new_password ||= if zxcvbn(new_password).fetch('score', 0) > 1
                              true
                            else
                              flash.now[:error] = I18n.t('change_password.invalid_password')
                              false
                            end
  end

  def new_password
    @new_password ||= params[:new_password]
  end

  def password_related_info
    @password_related_info ||= [CASino.config.passwords[:all_users_related_info], user_related_info].compact.join(' ')
  end

  def user_related_info
    @user_related_info ||= current_user.extra_attributes.values.join(' ') if current_user
  end

  def zxcvbn(password)
    path = CASino::Engine.root.join('app/assets/javascripts/casino/zxcvbn.js.erb')
    src = ERB.new(File.open(path).read).result
    @context = ExecJS.compile(src)
    @context.eval("zxcvbn(#{password.to_json}, #{user_related_info.to_json})")
  end
end
