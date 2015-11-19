class UserMailer < ApplicationMailer
  def invite_email(user)
    @user = user
    @url  = "http://gop-trade.herokuapp.com?user_key=#{user.key}"
    mail(to: @user.email, subject: 'Your GOPTrade Access Link')
  end
end
