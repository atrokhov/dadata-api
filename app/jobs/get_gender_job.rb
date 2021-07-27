# frozen_string_literal: true

class GetGenderJob < ApplicationJob
  queue_as :default

  def perform(user)
    res = dadata_request(user)

    gender = nil

    if !res.read_body.include? 'status'
      gender_unformat = JSON.parse(res.read_body)[0]['gender']
      gender = gender_unformat == 'Ж' ? :female : :male
    else
      gender = :male
    end

    user.last_gender_update = DateTime.now
    user.gender = gender
    user.save!

    { gender: gender, last_gender_update: user.last_gender_update.strftime('%d %B %Y %T %Z') }
  end

  private

  def dadata_request(user)
    uri = URI.parse('https://cleaner.dadata.ru/api/v1/clean/name')

    creds = Rails.application.credentials

    header = {
      'Content-Type' => 'application/json',
      'Authorization' => creds.dadata_api_token,
      'X-Secret' => creds.dadata_secret
    }

    request = Net::HTTP::Post.new(uri.path, header)

    data = user.full_name.to_json
    request.body = "[#{data}]"

    Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') { |http| http.request(request) }
  end
end
