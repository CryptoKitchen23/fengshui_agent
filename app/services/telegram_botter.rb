require 'telegram/bot'
require "openai"

class TelegramBotter

  def ask_openai(message)
    prompt = message.text.gsub('/question', '').strip

    openai_key = Rails.application.credentials.dig(:openai_key)
    client = OpenAI::Client.new(access_token: openai_key)

    response = client.chat(
      parameters: {
        model: 'gpt-4o-mini',
        messages: [{ role: "user", content: prompt }],
        temperature: 0.7,
        max_tokens: 50,
      }
    )

    response
  end

  def start_bot(token)
    Telegram::Bot::Client.run(token, environment: :test) do |bot|
      Rails.application.config.telegram_bot = bot
      bot.api.get_updates(offset: -1)

      bot.listen do |message|
        puts "Received message: #{message}"
        if message.text.start_with?('/question')
          puts "You asked a question in the chat with id: #{message.chat.id}"
          response = ask_openai(message)
          if response
            bot.api.send_message(chat_id: message.chat.id, text: response.dig("choices", 0, "message", "content") || "No response")
          else
            bot.api.send_message(chat_id: message.chat.id, text: 'Error processing your request')
          end
        end
      end
    end
  rescue Telegram::Bot::Exceptions::ResponseError => e
    Rails.logger.error "Telegram API Error: #{e.message}"
    Rails.logger.error "Error Code: #{e.error_code}" if e.respond_to?(:error_code)
    Rails.logger.error "Description: #{e.description}" if e.respond_to?(:description)
    Rails.logger.error "Parameters: #{e.parameters}" if e.respond_to?(:parameters)
    begin
      Rails.application.config.telegram_bot.api.delete_webhook
    rescue Telegram::Bot::Exceptions::ResponseError => inner_e
      Rails.logger.error "Inner Telegram API Error: #{inner_e.message}"
      Rails.logger.error "Error Code: #{inner_e.error_code}" if inner_e.respond_to?(:error_code)
      Rails.logger.error "Description: #{inner_e.description}" if inner_e.respond_to?(:description)
      Rails.logger.error "Parameters: #{inner_e.parameters}" if inner_e.respond_to?(:parameters)
    end
    Rails.application.config.telegram_bot.stop
  end

  Signal.trap("TERM") do
    puts "Shutting down bot..."
    Rails.application.config.telegram_bot.stop
    exit
  end

  Signal.trap("INT") do
    puts "Shutting down bot..."
    Rails.application.config.telegram_bot.stop
    exit
  end
end