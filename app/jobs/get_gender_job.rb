class GetGenderJob < ApplicationJob
  queue_as :default

  def perform(user)
    uri = URI.parse('https://cleaner.dadata.ru/api/v1/clean/name')
    request = Net::HTTP::Post.new(uri.path, initheader = {'Content-Type' =>'application/json'})

    request["Authorization"] = ENV['DADATA_AUTH_TOKEN']
    request["X-Secret"] = ENV['DADATA_SECRET']

    data = "#{user.full_name}".to_json
    request.body = "[#{data}]"

    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
      http.request(request)
    end

    gender = nil
    gender_unformat = JSON.parse(res.read_body)[0]['gender']
    
    if gender_unformat == "Ж"
      gender = :female
    else
      gender = :male
    end

    user.last_gender_update = DateTime.now
    user.gender = gender
    user.save!

    gender
  end
end
