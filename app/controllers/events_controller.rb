class EventsController < ApplicationController
  before_action :set_event, only: [:show, :edit, :update, :destroy, :invite_friends, :new_friend]
  before_action :set_user
  # GET /events
  # GET /events.json
  def index
    @events = Event.all
  end

  # GET /events/1
  # GET /events/1.json
  def show
    people = Role.where(event_id: @event.id)
    @people = people.map { |person| User.where(id: person.user_id)}.flatten
    @people_role = people
    @event.total_days
    expenses = @event.expenses
    @event.attendance
    @total_cost = 0
    @total_paid = 0
    paid_expenses = expenses.where(user_id: @user.id)
    paid_expenses.each do |expense|
      @total_paid += expense.amount.to_f
    end
    @type = expenses.map do |expense|
      if expense.calculation_type == "Groceries"
        @total_cost += expense.groceries
      elsif expense.calculation_type == "Boat"
        @total_cost += expense.boat
      elsif expense.calculation_type == "Gift"
        @total_cost += expense.gift
      end
    @total_owed = @total_cost - @total_paid
    end
    @pending_expenses = Expense.where(event_id: @event.id).where(approved: false)
  end

  # GET /events/new
  def new
    @event = Event.new
  end

  # GET /events/1/edit
  def edit
  end

  # POST /events
  # POST /events.json
  def create
    @event = Event.new(event_params)
    respond_to do |format|
      if @event.save
        @role = Role.create(permission: "owner", event_id: @event.id, user_id: @user.id, start_date: params[:event][:start_date], end_date: params[:event][:end_date])
        # format.html { redirect_to user_events_path(user_id: @user.id), notice: 'Event was successfully created.' }
        format.html { redirect_to event_path(id: @event.id), notice: 'Event was successfully created.' }

        format.json { render :show, status: :created, location: @event }
      else
        format.html { render :new }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /events/1
  # PATCH/PUT /events/1.json
  def update
    respond_to do |format|
      if @event.update(event_params)
        format.html { redirect_to user_events_path(user_id: @user.id), notice: 'Event was successfully updated.' }
        format.json { render :show, status: :ok, location: @event }
      else
        format.html { render :edit }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.json
  def destroy
    @event.destroy
    respond_to do |format|
      format.html { redirect_to user_events_path(user_id: @user.id), notice: 'Event was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def invite_friends
    @role = Role.new
  end

  def new_friend
    friend = User.find_by(email: params[:role][:user][:email])
    if friend
      @role = Role.new(user_id: friend.id, event_id: @event.id, start_date: params[:role][:start_date], end_date: params[:role][:end_date], permission: params[:role][:permission])
      if @role.save
        flash[:notice] = "Friend was successfully invited."
        redirect_to event_path(id: @event.id)
      else
        respond_to do |format|
          format.html { render :invite_friends }
          format.json { render json: @role.errors, status: :unprocessable_entity }
        end
      end
    else
      flash[:notice] = "This person is not a member. Would you like to invite them to join the site?"
      redirect_to event_invite_friends_path(event_id: @event.id)
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_event
      @event = Event.find(params[:id] || params[:event_id])
    end

    def set_user
      @user = User.find(session[:user_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def event_params
      params.require(:event).permit(:name, :users_title, :start_date, :end_date, :location, :image)
    end
end
