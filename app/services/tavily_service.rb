# TODO:
# Implement the TavilyService to search the reald time knowledge
# Such as crypto currencies news or Fengshui knowledge

require 'net/http'
require 'json'

class TavilySearchService
  TAVILY_API_URL = "https://api.tavily.com/search"
  TAVILY_API_KEY = Rails.application.credentials.dig(:tavily_key)

  def perform_search(query)
    uri = URI(TAVILY_API_URL)
    request = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
    request.body = {
      api_key: TAVILY_API_KEY,
      query: query,
      search_depth: "basic",
      include_answer: false,
      include_images: true,
      include_image_descriptions: true,
      include_raw_content: false,
      max_results: 5,
      include_domains: [],
      exclude_domains: []
    }.to_json

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    JSON.parse(response.body)["results"].map { |result| result["title"] }.join("\n")
  end
end