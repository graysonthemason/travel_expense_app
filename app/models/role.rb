
class Role < ActiveRecord::Base
  belongs_to :user
  belongs_to :event
  has_many :expenses
  validates :permission, :event_id, :user_id, presence: true
  validates :paid, :inclusion => {:in => [true, false]}
  validates :user, :uniqueness => {:scope => :event}

  def total_days
    (end_date - start_date).to_i
  end

  def is_owner?
    self.permission == "owner"
  end
  def is_organizer?
    self.permission == "organizer"
  end
  def is_friend?
    self.permission == "friend"
  end
end



# == Schema Information
#
# Table name: roles
#
#  id          :integer          not null, primary key
#  start_date  :date
#  end_date    :date
#  amount_owed :decimal(, )
#  permission  :string(255)
#  paid        :boolean          default(FALSE)
#  event_id    :integer
#  user_id     :integer
#  created_at  :datetime
#  updated_at  :datetime
#
