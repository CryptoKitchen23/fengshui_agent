require "openai"
require_relative "cmc_pump_fun_service"

class OpenAIService
  MAX_HISTORY_LENGTH = 15
  COIN_FETCH_INTERVAL = 24 * 60 * 60 # 1 day in seconds

  def initialize
    @client = OpenAI::Client.new(access_token: Rails.application.credentials.dig(:openai_key))
    @last_coin_fetch_time = Time.now - COIN_FETCH_INTERVAL
    @coins = []

    load_prompts
    fetch_coins_if_needed
  end

  def load_prompts
    @system_prompt = {
      role: 'system', content: Prompt.where(role: 'system').order(version: :desc).first.content
    }
    @pump_fun_prompt = {
      role: 'pump_fun', content: Prompt.where(role: 'pump_fun').order(version: :desc).first.content
    }
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
    Message.create!(
      user_id: user_id,
      role: role,
      content: content,
      msg_type: 'telegram'
    )
  end

  def get_response(user_id)
    reload_prompts
    messages = [@system_prompt] + Message.where(user_id: user_id).order(created_at: :asc).last(MAX_HISTORY_LENGTH).map do |msg|
      { role: msg.role, content: msg.content }
    end
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