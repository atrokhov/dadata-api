# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'users/index.html.slim', type: :view do
  it 'displays all the users' do
    assign(:users, [
             User.create!(email: 'test1@test.com', password: 'password', password_confirmation: 'password', role: :admin,
                          full_name: 'Атрохов Артур Эдуардович'),
             User.create!(email: 'test2@test.com', password: 'password', password_confirmation: 'password', role: :client,
                          full_name: 'Атрохова Янита')
           ])

    render

    expect(rendered).to match /Атрохов Артур Эдуардович/
    expect(rendered).to match /Атрохова Янита/
  end
end
