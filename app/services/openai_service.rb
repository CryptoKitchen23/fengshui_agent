require "openai"

class OpenAIService
  MAX_HISTORY_LENGTH = 15

  def initialize
    @chat_histories = Hash.new { |hash, key| hash[key] = [] }
    @client = OpenAI::Client.new(access_token: Rails.application.credentials.dig(:openai_key))
    @system_prompt = { role: "system", content: "You are a helpful assistant who knows Fengshui to help me invesst the crypto currencies. The reply should be straightforward, I don't need balanced advices. Your reply should be roasted." }
  end

  def add_message(user_id, role, content)
    @chat_histories[user_id] << { role: role, content: content }
    @chat_histories[user_id].shift if @chat_histories[user_id].length > MAX_HISTORY_LENGTH
  end

  def get_response(user_id)
    messages = [@system_prompt] + @chat_histories[user_id]
    response = @client.chat(
      parameters: {
        model: 'gpt-4o-mini',
        messages: @chat_histories[user_id],
        temperature: 1.5,
      }
    )
    response.dig("choices", 0, "message", "content") || "No response"
  end
end