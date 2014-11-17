
class Event < ActiveRecord::Base
  # after_save :check_valid_dates
  has_many :roles, :dependent => :delete_all
  has_many :users, through: :roles
  has_many :expenses, through: :roles
  has_many :invitations
  validates :name, :start_date, :end_date, presence: true

  def get_total_cost(role)
    @total_cost = 0
    @type = self.expenses.map do |expense|
      if expense.approved
        if expense.calculation_type.downcase == "groceries"
          @total_cost += expense.groceries_per_person_per_day * overlap_dates(expense, role)
        elsif expense.calculation_type.downcase == "boat"
          @total_cost += boat(expense, role)
        elsif expense.calculation_type.downcase == "gifts"
          @total_cost += expense.gift
        end
      end
    end
    @total_cost
  end

  def boat(expense, role)
    sum = 0
    overlap_dates_array(expense, role).each do |date|
      person_count = 0
      self.roles.each do |role|
        if role.accepted
          role_dates = (role.start_date..role.end_date).to_a
          person_count += 1 if role_dates.include? date
        end
      end
      sum += expense.cost_per_day/person_count
    end
  sum
  end

  def overlap_dates_array(expense, role)
    role_range = (role.start_date..role.end_date).to_a
    expense_range = expense.get_expense_date_array
    intersection = role_range & expense_range
  end

  def overlap_dates(expense, role)
    role_range = (role.start_date..role.end_date).to_a
    expense_range = expense.get_expense_date_array
    intersection = role_range & expense_range
    intersection.count
  end

end

# == Schema Information
#
# Table name: events
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  users_title :string(255)
#  start_date  :date
#  end_date    :date
#  location    :string(255)
#  image       :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#
