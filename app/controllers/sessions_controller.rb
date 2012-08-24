class SessionsController < ApplicationController
  skip_before_filter :require_yammer_login, only: [:create, :destroy]

  def create
    user = find_or_create_with_auth
    user.fetch_yammer_user_data
    cookies.signed[:yammer_user_id] = user.yammer_user_id
    log_out_guest
    set_referer_session_variable

    redirect_to after_sign_in_path
  end

  def destroy
    @current_user = nil
    log_out_guest
    cookies.signed[:yammer_user_id] = nil
    redirect_to root_path
  end

  private

  def after_sign_in_path
    if session[:return_to].blank?
      new_event_path
    else
      session.delete(:return_to)
    end
  end

  def auth
    request.env['omniauth.auth']
  end

  def find_or_create_with_auth
    User.find_or_create_with_auth(
        access_token: auth[:info][:access_token],
        yammer_staging: auth[:provider] == "yammer_staging",
        yammer_user_id: auth[:uid]
    )
  end

  def log_out_guest
    session[:name] = nil
    session[:email] = nil
  end

  def set_referer_session_variable
    begin
      referer = request.env["HTTP_REFERER"]

      if referer.include?('www.yammer.com')
        session[:referer] = 'yammer'
      elsif referer.include?('www.staging.yammer.com')
        session[:referer] = 'staging'
      else
        session[:referer] = nil
      end
    rescue NoMethodError
      session[:referer] = nil
    end
  end
end
