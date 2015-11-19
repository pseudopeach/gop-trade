class Trade < ActiveRecord::Base
  belongs_to :buyer, class_name: "User"
  belongs_to :seller, class_name: "User"
  belongs_to :candidate

  def send_notifications
    TradeMailer.execution_notification(self, buyer).deliver_later
    TradeMailer.execution_notification(self, seller).deliver_later
    self.notified_at = 0.seconds.ago
    save
  end
end
