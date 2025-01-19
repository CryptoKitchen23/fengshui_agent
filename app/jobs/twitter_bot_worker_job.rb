class TwitterBotWorkerJob < ApplicationJob
  queue_as :default

  def perform(credentials)
    client = X::Client.new(
      api_key: credentials[:api_key],
      api_key_secret: credentials[:api_key_secret],
      access_token: credentials[:access_token],
      access_token_secret: credentials[:access_token_secret]
    )

    since_id = 1

    loop do
      mentions = client.get('statuses/mentions_timeline', since_id: since_id)
      mentions.each do |mention|
        client.post('statuses/update', status: "@#{mention['user']['screen_name']} Thank you for the mention!", in_reply_to_status_id: mention['id'])
        since_id = mention['id'] if mention['id'] > since_id
      end
      sleep 60
    end
  end
end