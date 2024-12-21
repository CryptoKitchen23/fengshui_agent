#!/usr/bin/env ruby
#
# test_tg.rb
# Copyright (C) 2024 vagrant <vagrant@4db04eefe25e>
#
# Distributed under terms of the MIT license.
#

require 'telegram/bot'

token = '7330897348:AAFnWv1CeEuniI69JHJ7ESriFhc23p_hcr4'

Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    case message.text
    when '/start'
      bot.api.send_message(chat_id: message.chat.id, text: "Hello, #{message.from.first_name}")
    when '/stop'
      bot.api.send_message(chat_id: message.chat.id, text: "Bye, #{message.from.first_name}")
    end
  end
end