class User < ActiveRecord::Base
  has_many :reserves, class_name: "Reserve", foreign_key: 'owner_id', inverse_of: :owner
  has_many :offers, class_name: "TradeOffer", foreign_key: 'offerer_id', inverse_of: :offerer

  def self.add(name: nil, email:nil)
    u = User.new name:name, email:email
    u.save!
    u.start_season
    user_mailer.invite_email(u).deliver_now
  end

  def reserve_qty(resource_id: nil)
    if resource_id

      return reserves.where(resource_id: resource_id).load.first.qty
    else
      return Hash[reserves.all.load.map{|r| [r.resource_id, r.qty] }]
    end
  end

  def reserve_credit(share_count: nil, resource_id: nil)
    reserve_debit(share_count: share_count, resource_id: resource_id, credit:true)
  end

  def reserve_debit(share_count: nil, resource_id: nil, credit:false)
    self.transaction do
      if !credit && reserve_qty(resource_id:resource_id) < share_count
        raise ActiveRecord::Rollback
      end
      res = reserves.where(resource_id:resource_id).first
      res.qty -= share_count * (credit ? -1 : 1)
      res.save!
    end
  end

  def start_season
    self.key = SecureRandom.uuid
    self.save!

    Candidate.all.each do |c|
      self.reserves << Reserve.new(resource_id: c.id, qty:10)
    end
    self.reserves << Reserve.new(resource_id: 0, qty: 10*100)
  end

  def update_qtys
    qtys_on_hand = reserve_qty
    offers.where(closed_at:nil).each do |offer|
      offer.adjust_availability owner_share_qty: qtys_on_hand[offer.candidate_id], owner_cash: qtys_on_hand[0]
      offer.save!
    end
  end

end
