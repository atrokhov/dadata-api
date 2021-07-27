# frozen_string_literal: true

class GetGenderJob < ApplicationJob
  queue_as :default

  def perform(user)
    uri = URI.parse('https://cleaner.dadata.ru/api/v1/clean/name')
    request = Net::HTTP::Post.new(uri.path,
                                  {
                                    'Content-Type' => 'application/json',
                                    'Authorization' => Rails.application.credentials.dadata_api_token,
                                    'X-Secret' => Rails.application.credentials.dadata_secret
                                  })

    data = user.full_name.to_s.to_json
    request.body = "[#{data}]"

    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
      http.request(request)
    end

    if !res.read_body.include? 'status'
      gender_unformat = JSON.parse(res.read_body)[0]['gender']

      gender = if gender_unformat == 'Ж'
                 :female
               else
                 :male
               end

      user.last_gender_update = DateTime.now
      user.gender = gender
      user.save!

      { gender: gender, last_gender_update: user.last_gender_update.strftime('%d %B %Y %T %Z') }
    else
      'error'
    end
  end
end
