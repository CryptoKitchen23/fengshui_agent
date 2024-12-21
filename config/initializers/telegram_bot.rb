require 'telegram/bot'

Rails.application.config.after_initialize do
  puts "Running Telegram Bot Job!"
  TelegramBotWorkerJob.perform_later(Rails.application.credentials.dig(:telegram_bot))
end