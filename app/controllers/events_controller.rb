class EventsController < ApplicationController
  before_action :set_user
  before_action :authorize_admin_only,    only:   :index
  before_action :set_event, only: [:show, :edit, :update, :destroy, :invite_friends, :new_friend]
  before_action :set_role, only: [:show, :edit, :update, :destroy, :invite_friends, :new_friend]
  # GET /events
  # GET /events.json
  def index
    @events = Event.all
  end

  # GET /events/1
  # GET /events/1.json,
  def show
    @people = Role.where(event_id: @event.id).where(accepted: true)
    @pending_people = Role.where(event_id: @event.id).where(accepted: false)
    @invited_people = Invitation.where(event_id: @event.id).where(accepted: false)
    @total_cost = @event.get_total_cost(@role)
    @total_paid = 0
    @role.expenses.each { |expense| @total_paid += expense.amount.to_f if expense.approved}
    @total_owed = @total_cost - @total_paid
    @pending_expenses = @event.expenses.where(approved: false)
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
        @role = Role.create(permission: "owner", accepted: true, event_id: @event.id, user_id: @user.id, start_date: params[:event][:start_date], end_date: params[:event][:end_date])
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
    if params[:friend]
      role = Role.where(user_id: @user.id).where(event_id: @event.id)[0]
      role.accepted = true
      respond_to do |format|
        if role.save
          format.html { redirect_to event_path(id: @event.id), notice: 'Event was successfully updated.' }
          format.json { render :show, status: :ok, location: @event }
        else
          format.html { render :edit }
          format.json { render json: @event.errors, status: :unprocessable_entity }
        end
      end
    elsif params[:finalize]
      Role.where("event_id = ? AND accepted = ?", @event.id, false).destroy_all
      @event.roles.each do |role|
        total_cost = @event.get_total_cost(role)
        total_paid = 0
        role.expenses.each { |expense| total_paid += expense.amount.to_f }
        total_owed = total_cost - total_paid
         role.amount_owed = total_owed
         role.save
      end
      @event.closed = true
      @event.save
      redirect_to event_path(id: @event.id)
    else
      respond_to do |format|
        if @event.update(event_params)
          format.html { redirect_to event_path(id: @event.id), notice: 'Event was successfully updated.' }
          format.json { render :show, status: :ok, location: @event }
        else
          format.html { render :edit }
          format.json { render json: @event.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.json
  def destroy
    if params[:friend]
      @role.destroy
      respond_to do |format|
        format.html { redirect_to user_path(user_id: @user.id), notice: 'Expense was successfully destroyed.' }
        format.json { head :no_content }
      end
    else
      @event.destroy
      respond_to do |format|
        format.html { redirect_to user_path(user_id: @user.id), notice: 'Event was successfully destroyed.' }
        format.json { head :no_content }
      end
    end
  end

  def invite_friends
    if params[:new_email]
      @new_email = params[:new_email]
      @invitation = Invitation.new
    end
    @role = Role.new
  end

  def new_friend
    friend = User.find_by(email: params[:role][:user][:email])
    if friend
      @role = Role.new(user_id: friend.id, event_id: @event.id, start_date: @event.start_date, end_date: @event.end_date, permission: params[:role][:permission])
      if @role.save
        flash[:success] = "#{User.find(friend.id).email} was successfully invited."
        redirect_to event_path(id: @event.id)
      else
        respond_to do |format|
          format.html { render :invite_friends }
          format.json { render json: @role.errors, status: :unprocessable_entity }
        end
      end
    else
      new_email = params[:role][:user][:email]
      permission = params[:role][:permission]
      flash[:notice] = "#{new_email} is not a member. Would you like to invite them to join the site?"
      redirect_to new_invitation_path(event_id: @event.id, new_email: new_email, owner: @user.id, permission: permission)
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

    def set_role
      @role = Role.where("event_id = ? AND user_id = ?", @event.id, @user.id).first
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def event_params
      params.require(:event).permit(:name, :users_title, :start_date, :end_date, :location, :image)
    end
end
