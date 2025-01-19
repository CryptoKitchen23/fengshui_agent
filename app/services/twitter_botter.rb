require 'x'
require_relative 'openai_service'

class TwitterBotter
  def initialize
    @openai_service = OpenAIService.new
    @credentials = {
      api_key:             Rails.application.credentials.dig(:twitter, :api_key),
      api_key_secret:      Rails.application.credentials.dig(:twitter, :api_key_secret),
      access_token:        Rails.application.credentials.dig(:twitter, :access_token),
      access_token_secret: Rails.application.credentials.dig(:twitter, :access_token_secret),
    }
    @client = X::Client.new(**@credentials)
    @fengshui_agent_user_id = '1798976217863057408'
    @replied_mentions = Set.new
  end

  def start_bot
    loop do
      check_mentions
      # Free tier limit 1 request per 15 min in GET /2/users/:id/mentions
      Rails.logger.info "Sleeping for 15 min..."
      sleep(60 * 15)
    end
  rescue StandardError => e
    Rails.logger.error e
  end

  private

  def check_mentions
    response = @client.get("users/#{@fengshui_agent_user_id}/mentions")
    return unless response.key?('data')

    response['data'].each do |mention|
      unless replied_to_mention?(mention['id'])
        reply_to_mention(mention)
      end
    end
  end

  def replied_to_mention?(mention_id)
    @replied_mentions.include?(mention_id)
  end

  def reply_to_mention(mention)
    user_id = mention['author_id']
    prompt = mention['text']
    @openai_service.add_message(user_id, "user", prompt)

    response_text = @openai_service.get_response(user_id)
    reply_text = "@#{mention['username']} #{response_text}"
    response = @client.post("statuses/update", { status: reply_text, in_reply_to_status_id: mention['id'] })

    if response.key?('id')
      @replied_mentions.add(mention['id'])
      @openai_service.add_message(user_id, "assistant", response_text)
    end
  end
end