class Reserve < ActiveRecord::Base
  belongs_to :owner, class_name: "User", inverse_of: :reserves
  belongs_to :resource, class_name: "Candidate"

end