# README

Fengshui Agent leverages Generative AI and Feng Shui to Discover the Right Memecoins for You

What is Feng Shui:
It’s an ancient divination practice rooted in East Asian philosophy and metaphysics.
Translated as "wind" (Feng) and "water" (Shui), it emphasizes the harmonious interaction between individuals and their surroundings.
How does the Feng Shui Agent work?
Central to Feng Shui are the concepts of Qi (vital life force) and the Five Elements—wood, fire, earth, metal, and water—which together create balance and alignment.
The philosophy is simple: Success in trading isn’t just about timing or trends — it’s about energy alignment.
Every trader has a unique energy
Every memecoin carries its energy
FengShui Agent uses cutting-edge LLMs to analyze both and find the perfect match for your trading journey.

* Ruby version
    3.3.1

* Configuration
    Please provide the secret key base in the environment variable
    using `EDITOR="vim" rails credentials:edit`
    ```
    # Open AI API Key
    openai_key:

    # Telegram API key
    telegram_bot:

    # CoinMarketCap API Key
    cmc_key:
    ...
    ```

* More services to roll out in the `app/services` folder