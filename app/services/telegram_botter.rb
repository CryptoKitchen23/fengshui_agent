require 'telegram/bot'
require_relative 'openai_service'

class TelegramBotter
  def initialize
    @openai_service = OpenAIService.new
  end

  def start_bot(token)
    Telegram::Bot::Client.run(token) do |bot|
      Rails.application.config.telegram_bot = bot
      bot.api.get_updates(offset: -1)

      bot.listen do |message|
        puts "Received message: #{message}"
        user_id = message.from.id

        if message.text.start_with?('/question')
          prompt = message.text.gsub('/question', '').strip
          @openai_service.add_message(user_id, "user", prompt)

          puts "You asked a question in the chat id: #{message.chat.id} from user id: #{message.from.id}"
          response = @openai_service.get_response(user_id)
          bot.api.send_message(chat_id: message.chat.id, text: response)

          @openai_service.add_message(user_id, "assistant", response)
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
end