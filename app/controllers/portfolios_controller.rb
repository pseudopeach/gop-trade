class PortfoliosController < ApplicationController
  before_action :get_user, except: [:not_logged_in]

  def index
    reserves = @user.reserves.includes(:resource).to_a
    @candidate_reserves = reserves.select(&:resource)
    @money_reserve = reserves.select{|r| r.resource_id == 0}.first
  end

  def not_logged_in
    render 'not_logged_in', layout:false
  end

  private
  def get_user
    @user = User.find(session[:user_id])
  end

end