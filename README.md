# Hubot Telegram Adapter

[Hubot](https://hubot.github.com/docs/) adapter for interfacting with the [Telegram Bot API](https://core.telegram.org/bots/api)

## Installation & Usage

First of read the docs on how to create a new [Telegram Bot](https://core.telegram.org/bots#botfather). Once you have a bot created, follow these steps:

* npm install --save hubot-telegram
* Set the environment variables specified in **Configuration**
* Run hubot `bin/hubot -a telegram`

## Configuration

This adapter uses the following environment variables:

*TELEGRAM_TOKEN* (required)

The token that the [BotFather](https://core.telegram.org/bots#botfather) gives you

*TELEGRAM_WEBHOOK* (optional)

You can specify a [webhook](https://core.telegram.org/bots/api#setwebhook) URL which the adapter will register with Telegram. This URL will receive updates from Telegram. The adapter automatically registers an endpoint with Hubot at http://your-hobot-host/hubot/telegram/receive.

*TELEGRAM_PRIVACY* (optional)

Telegram has a [privacy mode](https://core.telegram.org/bots#privacy-mode) that can be enabled for group chats. If this feature is enabled on your bot, you need to specify this value as true so that the adapter can strip out the extra characters that don't form part of the hubot message.

Example.

"/hubot, ship it" becomes "hubot, ship it"
"@my_bot_username hubot, ship it" becomes "hubot, ship it"

*TELEGRAM_INTERVAL* (optional)

You can specify the interval (in milliseconds) in which the adapter will poll Telegram for updates. This option only applies if you are not using a [webhook](https://core.telegram.org/bots/api#setwebhook).