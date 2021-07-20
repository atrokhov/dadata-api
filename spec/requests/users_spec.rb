require 'rails_helper'

RSpec.describe "Users", type: :request do
  describe "GET /index" do
    it "returns http found and redirect to login page if user is not authorized" do
      get "/users"
      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(new_user_session_url)
    end

    it "returns http found and redirect to edit user page if user is client" do
      user = User.create(email: 'test@test.com', password: "password", password_confirmation: "password", role: :client, full_name: "Атрохов Артур Эдуардович")
      sign_in user
      get "/users"
      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(edit_user_url(user))
    end

    it "returns http success if user is admin" do
      admin = User.create(email: 'admin@test.com', password: "password", password_confirmation: "password", role: :admin, full_name: "Атрохов Артур Эдуардович")
      sign_in admin
      get "/users"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /edit" do
    it "returns http found and redirect to login page if user is not authorized" do
      user = User.create(email: 'test@test.com', password: "password", password_confirmation: "password", role: :client, full_name: "Атрохов Артур Эдуардович")
      get "/users/#{user.id}/edit"
      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(new_user_session_url)
    end

    it "returns http success if user is client" do
      user = User.create(email: 'test@test.com', password: "password", password_confirmation: "password", role: :client, full_name: "Атрохов Артур Эдуардович")
      sign_in user
      get "/users/#{user.id}/edit"
      expect(response).to have_http_status(:success)
    end

    it "returns http success if user is admin" do
      user = User.create(email: 'test@test.com', password: "password", password_confirmation: "password", role: :admin, full_name: "Атрохов Артур Эдуардович")
      sign_in user
      get "/users/#{user.id}/edit"
      expect(response).to have_http_status(:success)
    end

    it "returns http success and data of this user if user is client, despite of another id" do
      user1 = User.create(email: 'test1@test.com', password: "password", password_confirmation: "password", role: :client, full_name: "Атрохов Артур Эдуардович")
      user2 = User.create(email: 'test2@test.com', password: "password", password_confirmation: "password", role: :client, full_name: "Атрохов Ростислав Эдуардович")
      sign_in user1
      get "/users/#{user2.id}/edit"
      expect(response).to have_http_status(:success)
      expect(response.body).to include user1.full_name 
    end

    it "returns http success and data of another user if user is admin" do
      user1 = User.create(email: 'test1@test.com', password: "password", password_confirmation: "password", role: :admin, full_name: "Атрохов Артур Эдуардович")
      user2 = User.create(email: 'test2@test.com', password: "password", password_confirmation: "password", role: :client, full_name: "Атрохов Ростислав Эдуардович")
      sign_in user1
      get "/users/#{user2.id}/edit"
      expect(response).to have_http_status(:success)
      expect(response.body).to include user2.full_name 
    end

    it "returns http success and data of current user if user is admin" do
      user1 = User.create(email: 'test1@test.com', password: "password", password_confirmation: "password", role: :admin, full_name: "Атрохов Артур Эдуардович")
      sign_in user1
      get "/users/#{user1.id}/edit"
      expect(response).to have_http_status(:success)
      expect(response.body).to include user1.full_name 
    end
  end

  describe "GET /get_gender" do
    it "returns http success and can get edit" do
      user1 = User.create(email: 'test1@test.com', password: "password", password_confirmation: "password", role: :client, full_name: "Атрохов Артур Эдуардович")
      sign_in user1
      get "/users/#{user1.id}/get_gender"
      expect(response).to have_http_status(:success)
      expect(response.body).to include "gender"
    end

    it "returns http success and user can get only self gender" do
      user1 = User.create(email: 'test1@test.com', password: "password", password_confirmation: "password", role: :client, full_name: "Атрохов Артур Эдуардович")
      user2 = User.create(email: 'test2@test.com', password: "password", password_confirmation: "password", role: :client, full_name: "Атрохова Янита")
      sign_in user1
      get "/users/#{user2.id}/get_gender"
      expect(response).to have_http_status(:success)
      puts response.body
      expect(response.body).to include "male"
    end
  end

end
