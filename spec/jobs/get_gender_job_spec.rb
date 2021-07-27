# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GetGenderJob, type: :job do
  describe '#perform_now' do
    it 'get gender' do
      user = User.create!(email: 'test1@test.com', password: 'password', password_confirmation: 'password',
                          role: :admin, full_name: 'Атрохов Артур Эдуардович')
      ActiveJob::Base.queue_adapter = :test
      job = GetGenderJob.perform_now(user)
      expect(job[:gender]).to eq :male
      expect(job).to include :last_gender_update
    end
  end
end
