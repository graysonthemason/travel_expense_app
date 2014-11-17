
class Expense < ActiveRecord::Base
  belongs_to :role
  has_one 	 :user, through: :role
  has_one 	 :event, through: :role
  validates  :item, 	:amount, :calculation_type, presence: true
  validates  :role_id, presence: true
  validates  :approved, :inclusion => {:in => [true, false]}

	def total_days
		(end_date - start_date).to_i
	end

  def groceries_per_person_per_day
    (amount.to_f / people_days)
  end

  def people_days
    @expense_dates = get_expense_date_array
    sum = 0
    self.event.roles.each do |role|
      if role.accepted
        role_dates = (role.start_date..role.end_date).to_a
        intersection = @expense_dates & role_dates
        sum += intersection.count
      end
    end
    sum
  end

  def get_expense_date_array
    (self.start_date..self.end_date).to_a
  end

  def cost_per_day
    self.amount.to_f / self.get_expense_date_array.count
  end

	def gift
	  amount.to_f / event.roles.select { |role|  role if role.accepted }.count
	end

  def calculate_owed
    if calculation_type.downcase == "groceries"
      groceries
    elsif calculation_type.downcase == "boat"
      boat
    elsif calculation_type.downcase == "gifts"
      gift
    end
  end
end

# == Schema Information
#
# Table name: expenses
#
#  id               :integer          not null, primary key
#  item             :string(255)
#  amount           :decimal(, )
#  description      :string(255)
#  start_date       :date
#  end_date         :date
#  calculation_type :string(255)
#  tag              :string(255)
#  approved         :boolean          default(FALSE)
#  event_id         :integer
#  created_at       :datetime
#  updated_at       :datetime
#  user_id          :integer
#
