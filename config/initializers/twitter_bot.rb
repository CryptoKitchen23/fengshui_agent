require 'x'

Rails.application.config.after_initialize do
  puts "Disable Running Twitter Bot Job!"
  # TwitterBotWorkerJob.perform_later
end