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
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def get_gender
    uri = URI.parse('https://cleaner.dadata.ru/api/v1/clean/name')
    request = Net::HTTP::Post.new(uri.path, initheader = {'Content-Type' =>'application/json'})

    request["Authorization"] = ENV['DADATA_AUTH_TOKEN']
    request["X-Secret"] = ENV['DADATA_SECRET']

    data = "#{@user.surname} #{@user.name} #{@user.patronymic}".to_json
    request.body = "[#{data}]"

    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
      http.request(request)
    end

    gender = JSON.parse(res.read_body)[0]['gender']

    case gender
    when 'Ж'
      @user.gender = :female
    else
      @user.gender = :male
    end

    @user.last_gender_update = DateTime.now
    @user.save
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
    params.require(:user).permit(:name, :surname, :patronymic, :gender, :email)
  end
end
