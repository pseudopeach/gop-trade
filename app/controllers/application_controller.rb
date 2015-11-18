class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :check_key, except:['not_logged_in']

  private
  def check_key
    if user_key = params[:user_key]
      @user = User.where(key:user_key).first
      if @user
        session[:user_id] = @user.id
      end
    end
    unless session[:user_id]
      redirect_to '/not-logged-in'
      false
    end
  end
end
