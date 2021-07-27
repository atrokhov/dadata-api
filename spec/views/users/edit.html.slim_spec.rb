# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'users/edit.html.slim', type: :view do
  it 'displays edit user' do
    assign(:user,
           User.create(email: 'test1@test.com', password: 'password', password_confirmation: 'password', role: :client,
                       full_name: 'Атрохов Артур Эдуардович'))

    render

    expect(rendered).to match /Атрохов Артур Эдуардович/
    expect(rendered).to match /male/
  end
end
