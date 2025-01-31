require 'telegram/bot'
require_relative 'openai_service'

class TelegramBotter
  MAX_MESSAGE_LENGTH = 2048

  def initialize
    @openai_service = OpenAIService.new
    @telegram_bot_token = Rails.application.credentials.dig(:telegram_bot)
  end

  def start_bot()
    Telegram::Bot::Client.run(@telegram_bot_token) do |bot|
      Rails.application.config.telegram_bot = bot
      bot.api.get_updates(offset: -1)

      bot.listen do |message|
        puts "Received message: #{message}"
        user_id = message.from.id

        if message.text.start_with?('/q')
          prompt = message.text.gsub('/q', '').strip
          @openai_service.add_message(user_id, "user", prompt)

          puts "You asked a question in the chat id: #{message.chat.id} from user id: #{message.from.id}"
          response = @openai_service.get_response(user_id)
          send_response(bot, message.chat.id, response)

          @openai_service.add_message(user_id, "assistant", response)
        else
          response = "Fengshui Agent is practicing in retreat, can't answer your question right now."
          send_response(bot, message.chat.id, response)
        end
      end
    end
  rescue Telegram::Bot::Exceptions::ResponseError => e
    Rails.logger.error e
    Rails.application.config.telegram_bot.stop
    Rails.application.config.telegram_bot.api.delete_webhook
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

  private

  def send_response(bot, chat_id, response)
    if response.length <= MAX_MESSAGE_LENGTH
      bot.api.send_message(chat_id: chat_id, text: response)
    else
      response.scan(/.{1,#{MAX_MESSAGE_LENGTH}}/m).each do |chunk|
        bot.api.send_message(chat_id: chat_id, text: chunk)
      end
    end
  end
end