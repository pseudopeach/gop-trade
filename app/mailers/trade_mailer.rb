class TradeMailer < ApplicationMailer
  def execution_notification(trade, user)
    @user = user
    @trade = trade
    @share_count = @user.reserves.where(resource_id: trade.candidate_id).first.qty
    @url  = "http://gop-trade.herokuapp.com?user_key=#{user.key}"
    mail(to: @user.email, subject: 'Trade Executed')
  end
end
