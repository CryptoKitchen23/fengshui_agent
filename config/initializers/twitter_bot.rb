require 'x'

Rails.application.config.after_initialize do
  puts "Running Twitter Bot Job!"

  TwitterBotWorkerJob.perform_later(Rails.application.credentials.dig(:twitter))
end