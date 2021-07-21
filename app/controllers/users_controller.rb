class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:edit, :update, :get_gender]

  def index
    if user_signed_in? and current_user.admin?
      @users = User.all
    elsif user_signed_in? and current_user.client?
      redirect_to edit_user_path(current_user)
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @user.update(users_params)
        format.html { redirect_to edit_user_path(@user), notice: "User was successfully updated." }
        format.js
        format.json { render json: :edit, status: :ok }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @sub.errors, status: :unprocessable_entity }
      end
    end
  end

  def get_gender
    gender = get_gender_request(@user)
    render json: gender, status: :ok
  end

  private

  def set_user
    if user_signed_in? and current_user.admin?
      @user = User.find(params[:id])
    elsif user_signed_in? and current_user.client?
      @user = User.find(current_user.id)
    end
  end

  def users_params
    params.require(:user).permit(:full_name, :email)
  end

  def get_gender_request(user)
    GetGenderJob.perform_now(user)
  end
end
