require 'net/http'
require 'json'

class CmcPumpFunService
  BASE_URL = 'https://pro-api.coinmarketcap.com/v1/cryptocurrency/category'
  # Pump.fun category id
  CATEGORY_ID = '674959bead474122c10944fc'

  def initialize(id: CATEGORY_ID)
    @id = CATEGORY_ID
    @api_key = Rails.application.credentials.dig(:cmc_key)
  end

  def fetch_coins
    uri = URI(BASE_URL)
    params = { id: @id, CMC_PRO_API_KEY: @api_key }
    uri.query = URI.encode_www_form(params)
    request = Net::HTTP::Get.new(uri)

    begin
      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(request)
      end

      data = JSON.parse(response.body)

      if data['status']['error_code'] == 0
        filter_fields(data['data']['coins'])
      else
        []
      end
    rescue StandardError => e
      Rails.logger.error("Failed to fetch coins: #{e.message}")
      []
    end
  end

  private

  def filter_fields(coins)
    # sample coin data
    # {
    #  "id": 33597,
    #  "name": "Fartcoin",
    #  "symbol": "FARTCOIN",
    #  "slug": "fartcoin",
    #  "num_market_pairs": 149,
    #  "date_added": "2024-10-23T17:42:55.000Z",
    #  "tags": [
    #    "memes",
    #    "solana-ecosystem",
    #    "ai-memes",
    #    "pump-fun-ecosystem",
    #    "terminal-of-truths",
    #    "binance-alpha"
    #  ],
    #  "max_supply": 1000000000,
    #  "circulating_supply": 999998256,
    #  "total_supply": 1000000000,
    #  "platform": {
    #    "id": 5426,
    #    "name": "Solana",
    #    "symbol": "SOL",
    #    "slug": "solana",
    #    "token_address": "9BB6NFEcjBCtnNLFko2FqVQBq8HHM13kCyYcdQbgpump"
    #  },
    #  "is_active": 1,
    #  "infinite_supply": false,
    #  "cmc_rank": 116,
    #  "is_fiat": 0,
    #  "self_reported_circulating_supply": 1000000000,
    #  "self_reported_market_cap": 740571632.175402,
    #  "tvl_ratio": null,
    #  "last_updated": "2024-12-22T23:05:00.000Z",
    #  "quote": {
    #    "USD": {
    #      "price": 0.740571632175402,
    #      "volume_24h": 128903137.791644,
    #      "volume_change_24h": -52.6786,
    #      "percent_change_1h": 0.30989645,
    #      "percent_change_24h": -8.21155265,
    #      "percent_change_7d": -13.61753751,
    #      "percent_change_30d": 108.48868082,
    #      "percent_change_60d": 1226.81005844,
    #      "percent_change_90d": 1148.8980352,
    #      "market_cap": 740570340.618476,
    #      "market_cap_dominance": 0.0226,
    #      "fully_diluted_market_cap": 740571632.18,
    #      "tvl": null,
    #      "last_updated": "2024-12-22T23:05:00.000Z"
    #    }
    #  }
    #}
    coins.map do |coin|
      {
        name: coin['name'],
        volume_change_24h: coin['quote']['USD']['volume_change_24h'],
        percent_change_1h: coin['quote']['USD']['percent_change_1h'],
        market_cap: coin['quote']['USD']['fully_diluted_market_cap']
      }
    end
  end
end