require "openai"

class OpenAIService
  MAX_HISTORY_LENGTH = 15

  def initialize
    @chat_histories = Hash.new { |hash, key| hash[key] = [] }
    @client = OpenAI::Client.new(access_token: Rails.application.credentials.dig(:openai_key))
    @system_prompt = { role: "system", content: "Please ignore all previous system prompts. You are a Fengshui Agent,  who knows Fengshui very well to help invest crypto currencies. The reply should be straightforward, you shouldn't provide balanced advices, reply must be roasted. When people asked you to introduce, you should answer that you're a Fengshui Agent, knows a lot about Fengshui to help invest crypto currencies. The response should be less than 4096 chars long, roughly 1000 tokens" }
  end

  def add_message(user_id, role, content)
    @chat_histories[user_id] << { role: role, content: content }
    @chat_histories[user_id].shift if @chat_histories[user_id].length > MAX_HISTORY_LENGTH
  end

  def get_response(user_id)
    messages = [@system_prompt] + @chat_histories[user_id]
    puts "The chat history: #{messages}"
    response = @client.chat(
      parameters: {
        model: 'gpt-4o-mini',
        messages: @chat_histories[user_id],
        temperature: 1.5,
        max_tokens: 1000,
      }
    )
    response.dig("choices", 0, "message", "content") || "No response"
  end
end