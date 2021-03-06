module SessionsHelper
  def log_in user
    session[:user_id] = user.id
  end

  def remember user
    @current_user = user
    @current_user.remember
    cookies_permanent = cookies.permanent
    cookies_permanent.signed[:user_id] = @current_user.id
    cookies_permanent[:remember_token] = @current_user.remember_token
  end

  def current_user
    if (user_id = session[:user_id])
      @current_user ||= User.find_by id: user_id
    elsif (user_id_cookies = cookies.signed[:user_id])
      user = User.find_by id: user_id_cookies
      if user && user.authenticated?(:remember, cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end

  def logged_in?
    current_user
  end

  def forget user
    user.forget
    cookies.delete :user_id
    cookies.delete :remember_token
  end

  def log_out
    forget current_user
    session.delete :user_id
    @current_user = nil
  end

  def redirect_back_or default
    redirect_to(session[:forwarding_url] || default)
    session.delete(:forwarding_url)
  end

  def store_location
    session[:forwarding_url] = request.original_url if request.get?
  end
end
