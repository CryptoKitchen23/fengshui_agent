require 'net/http'
require 'json'

class GmgnSolService
  BASE_URL = 'https://gmgn.ai/defi/quotation/v1/rank/sol/pump'

  def fetch_recommendations(limit: 20, orderby: 'usd_market_cap', direction: 'desc', pump: true, 
    fields: [:created_timestamp, :name, :website])
    uri = URI(BASE_URL)
    params = { limit: limit, orderby: orderby, direction: direction, pump: pump }
    uri.query = URI.encode_www_form(params)

    request = Net::HTTP::Get.new(uri)
    request['Cookie'] = Rails.application.credentials.dig(:gmgn_cookies)
    request['User-Agent'] = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:128.0) Gecko/20100101 Firefox/128.0'
    puts request

    begin
      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(request)
      end
      
      puts response.body

      data = JSON.parse(response.body)

      if data['code'] == 0
        filter_fields(data['data']['rank'], fields)
      else
        []
      end
    rescue StandardError => e
      Rails.logger.error("Failed to fetch recommendations: #{e.message}")
      []
    end
  end

  private

  def filter_fields(recommendations, fields)
    recommendations.map do |rec|
      rec.symbolize_keys.slice(*fields)
    end
  end
end