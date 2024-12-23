require "openai"
require_relative "cmc_pump_fun_service"

class OpenAIService
  MAX_HISTORY_LENGTH = 15

  def initialize
    @chat_histories = Hash.new { |hash, key| hash[key] = [] }
    @client = OpenAI::Client.new(access_token: Rails.application.credentials.dig(:openai_key))
    @system_prompt = load_system_prompt
    
    coins = get_pump_fun_recommendations()
    if coins.any?
      pump_fun_prompt = load_pump_fun_prompt
      @system_prompt[:content] += "\n #{coins}} \n #{pump_fun_prompt[:content]} "
    end
  end

  def load_system_prompt
    config = YAML.load_file(Rails.root.join('config', 'prompts', 'system_prompt.yml'))
    config.symbolize_keys
  end

  def load_pump_fun_prompt
    config = YAML.load_file(Rails.root.join('config', 'prompts', 'pump_fun_prompt.yml'))
    config.symbolize_keys
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
        messages: messages,
        temperature: 1.0,
        max_tokens: 500,
      }
    )
    response.dig("choices", 0, "message", "content") || "No response"
  end

  def get_pump_fun_recommendations()
    cmc_service = CmcPumpFunService.new
    coins = cmc_service.fetch_coins
  end
end