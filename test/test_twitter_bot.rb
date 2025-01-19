require 'test_helper'
require 'x'

class TestTwitterBot < ActiveSupport::TestCase
  def setup
    @credentials = {
      api_key:             Rails.application.credentials.dig(:twitter, :api_key),
      api_key_secret:      Rails.application.credentials.dig(:twitter, :api_key_secret),
      access_token:        Rails.application.credentials.dig(:twitter, :access_token),
      access_token_secret: Rails.application.credentials.dig(:twitter, :access_token_secret),
    }
    @client = X::Client.new(**@credentials)
  end

  # def test_twitter_connection
  #   response = @client.get('users/me')
  #   puts response
  #   assert response.key?('data'), 'No data key in response'
  #   assert response['data'].key?('id'), 'No id key in data'
  #   assert response['data'].key?('name'), 'No name key in data'
  #   assert response['data'].key?('username'), 'No username key in data'
  # end

  def test_twitter_mentions
    # Free tier limit 1 request per 15 min in GET /2/users/:id/mentions
    fengshui_agent_user_id = '1798976217863057408'
    start_time = (Time.now - 60 * 15).utc.strftime('%Y-%m-%dT%H:%M:%SZ')
    response = @client.get("users/#{fengshui_agent_user_id}/mentions?start_time=#{start_time}")
    puts response
    # assert response.key?('data'), 'No data key in response'
    # assert response['data'].is_a?(Array), 'Data is not an array'
  end
end