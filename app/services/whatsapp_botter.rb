# TODO:
# Implement the Whatsapp bot service

# require 'twilio-ruby'
# require_relative 'openai_service'
#
# class WhatsAppBotter
#   MAX_MESSAGE_LENGTH = 2048
#
#   def initialize
#     @openai_service = OpenAIService.new
#     @client = Twilio::REST::Client.new(ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN'])
#     @from = "whatsapp:#{ENV['TWILIO_WHATSAPP_NUMBER']}"
#   end
#
#   def start_bot
#     loop do
#       messages = @client.messages.list(from: @from)
#       messages.each do |message|
#         next if message.direction == 'outbound-api'
#
#         puts "Received message: #{message.body}"
#         user_id = message.from
#
#         if message.body.start_with?('/q')
#           prompt = message.body.gsub('/q', '').strip
#           @openai_service.add_message(user_id, "user", prompt)
#
#           puts "You asked a question from user id: #{user_id}"
#           response = @openai_service.get_response(user_id)
#           send_response(user_id, response)
#
#           @openai_service.add_message(user_id, "assistant", response)
#         else
#           response = "Fengshui Agent is practicing in retreat, can't answer your question right now."
#           send_response(user_id, response)
#         end
#       end
#       sleep(5) # Poll every 5 seconds
#     end
#   rescue StandardError => e
#     puts "Error: #{e.message}"
#   end
#
#   Signal.trap("TERM") do
#     puts "Shutting down bot..."
#     exit
#   end
#
#   Signal.trap("INT") do
#     puts "Shutting down bot..."
#     exit
#   end
#
#   private
#
#   def send_response(to, response)
#     if response.length <= MAX_MESSAGE_LENGTH
#       @client.messages.create(
#         from: @from,
#         to: to,
#         body: response
#       )
#     else
#       response.scan(/.{1,#{MAX_MESSAGE_LENGTH}}/m).each do |chunk|
#         @client.messages.create(
#           from: @from,
#           to: to,
#           body: chunk
#         )
#       end
#     end
#   end
# end