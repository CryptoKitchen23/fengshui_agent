require "openai"
require_relative "cmc_pump_fun_service"

class OpenAIService
  MAX_HISTORY_LENGTH = 15
  COIN_FETCH_INTERVAL = 24 * 60 * 60 # 1 day in seconds

  def initialize
    @chat_histories = Hash.new { |hash, key| hash[key] = [] }
    @client = OpenAI::Client.new(access_token: Rails.application.credentials.dig(:openai_key))
    @last_coin_fetch_time = Time.now - COIN_FETCH_INTERVAL
    @coins = []

    load_prompts
    fetch_coins_if_needed
  end

  def load_prompts
    config = YAML.load_file(Rails.root.join('config', 'prompts', 'prompts.yml'))
    @system_prompt = config['system_prompt'].symbolize_keys
    @pump_fun_prompt = config['pump_fun_prompt'].symbolize_keys
  end

  def reload_prompts
    load_prompts
    fetch_coins_if_needed
    @system_prompt[:content] += "\n #{@coins.join(', ')} \n #{@pump_fun_prompt[:content]} " if @coins.any?
  end

  def fetch_coins_if_needed
    if Time.now - @last_coin_fetch_time >= COIN_FETCH_INTERVAL
      @coins = get_pump_fun_recommendations
      puts "Fetched coins: #{@coins}"
      @last_coin_fetch_time = Time.now
    end
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