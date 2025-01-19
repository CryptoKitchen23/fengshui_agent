class TwitterBotWorkerJob < ApplicationJob
  queue_as :default

  def perform
    puts "Starting Twitter Bot..."
    Rails.logger.info "Starting Twitter Bot..."
    twitter_bot = TwitterBotter.new
    twitter_bot.start_bot
  end
end