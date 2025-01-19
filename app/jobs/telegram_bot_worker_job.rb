class TelegramBotWorkerJob < ApplicationJob
  queue_as :default

  def perform()
    Rails.logger.info "Starting Telegram Bot..."
    telegram_bot = TelegramBotter.new
    telegram_bot.start_bot
  end
end