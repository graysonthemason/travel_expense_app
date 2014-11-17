class UsersController < ApplicationController
  # before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :authenticate,            except: [:new, :create]
  before_action :load_user,               except: [:index, :new, :create]
  before_action :authorize_admin_only,    only:   :index
  before_action :authorize_user_only,     only:   :show
  before_action :authorize_user_or_admin, except: [:index, :show, :new, :create]

  # GET /users
  # GET /users.json
  def index
    authorize_admin_only
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @owner ||= Role.where(user_id: params[:id].to_i).where(permission: "owner")
    @organizer ||= Role.where("user_id = ? AND permission = ?", params[:id].to_i, "organizer")
    @friend ||= Role.where(user_id: params[:id].to_i).where(permission: "friend")
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  # TODO write this tomorrow morning
  def edit

  end

    def update
    if @user.update(user_params)
      redirect_to user_path(@user)
    else
      render(:edit)
    end
  end

    # GET /users/1/password
  def password
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)
    if @user.save
      log_in(@user)
      invites = Invitation.where(email: @user.email)
      invites.each do |invite|
        event = Event.find(invite.event_id)
        Role.create(start_date: event.start_date,
                    end_date: event.end_date,
                    permission: invite.permission,
                    event_id: event.id,
                    user_id: @user.id
                    )
        Invitation.find(invite.id).destroy
      end
      redirect_to user_path(@user)
    else
      flash[:error] = "There was an issue with your sign up please try again"
      render :new
    end
  end

  # PATCH/PUT /users/1
  def update
    if params[:role_id]
        role = Role.find(params[:role_id].to_i)
        role.start_date = params[:role][:start_date]
        role.end_date = params[:role][:end_date]
        role.save
        redirect_to user_path(@user.id)
    else
      if @user.update(user_params)
        redirect_to user_path(@user)
      else
        render(:edit)
      end
    end
  end

    # PATCH/PUT /users/1/password
  def update_password
    if !@user.authenticate(user_password_params[:old_password])
      @user.errors.add(:old_password, 'must match the current password')
      render(:password)
    elsif user_password_params[:password].blank?
      @user.errors.add(:new_password, 'can\'t be blank!')
      render(:password)
    elsif @user.update(user_password_params.except(:old_password))
      flash[:notice] = "Your password has been updated!"
      redirect_to user_path(@user)
    else
      render(:password)
    end
  end

 # DELETE /users/1
  def destroy
    if current_user == @user
      @user.destroy
      log_out!
      flash[:notice] = "Thanks for the memories..."
      redirect_to(root_path)
    else # admin is deleting...
      @user.destroy
      redirect_to(users_path)
    end
  end

  def confirm_delete
  end


  private

  def user_params
    params.require(:user).permit(
      :email,
      :name,
      :image,
      :password,
      :password_confirmation
    )
  end

  def user_password_params
    @user_password_params ||= params.require(:user).permit(
      :old_password,
      :password,
      :password_confirmation
    )
  end

  def load_user
    @user = User.find_by(id: params[:id])
    redirect_to root_path if !@user
  end

  def authorize_admin_only
    unless current_user.is_admin?
      redirect_to user_path(current_user)
    end
  end

  def authorize_user_only
    unless current_user == @user
      redirect_to user_path(current_user)
    end
  end

  def authorize_user_or_admin
    unless current_user == @user || current_user.is_admin?
      redirect_to user_path(current_user)
    end
  end
end
