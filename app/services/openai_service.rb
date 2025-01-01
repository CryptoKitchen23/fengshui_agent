require "openai"
require_relative "cmc_pump_fun_service"

class OpenAIService
  MAX_HISTORY_LENGTH = 15

  def initialize
    @chat_histories = Hash.new { |hash, key| hash[key] = [] }
    @client = OpenAI::Client.new(access_token: Rails.application.credentials.dig(:openai_key))
    load_prompts

    coins = get_pump_fun_recommendations()
    if coins.any?
      @system_prompt[:content] += "\n #{coins} \n #{@pump_fun_prompt[:content]} "
    end
  end

  def load_prompts
    config = YAML.load_file(Rails.root.join('config', 'prompts', 'prompts.yml'))
    @system_prompt = config['system_prompt'].symbolize_keys
    @pump_fun_prompt = config['pump_fun_prompt'].symbolize_keys
  end

  def reload_prompts
    load_prompts
  end

  def add_message(user_id, role, content)
    @chat_histories[user_id] << { role: role, content: content }
    @chat_histories[user_id].shift if @chat_histories[user_id].length > MAX_HISTORY_LENGTH
  end

  def get_response(user_id)
    reload_prompts
    messages = [@system_prompt] + @chat_histories[user_id]
    puts "The chat history: #{messages}"
    response = @client.chat(
      parameters: {
        model: 'gpt-4o-mini',
        messages: messages,
        temperature: 1.0,
        max_tokens: 250,
      }
    )
    response.dig("choices", 0, "message", "content") || "No response"
  end

  def get_pump_fun_recommendations
    cmc_service = CmcPumpFunService.new
    cmc_service.fetch_coins
  end
end