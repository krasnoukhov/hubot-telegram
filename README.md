# Hubot Telegram Adapter

[Hubot](https://hubot.github.com/docs/) adapter for interfacting with the [Telegram Bot API](https://core.telegram.org/bots/api)

## Installation & Usage

First of read the docs on how to create a new [Telegram Bot](https://core.telegram.org/bots#botfather). Once you have a bot created, follow these steps:

* npm install --save hubot-telegram
* Set the environment variables specified in **Configuration**
* Run hubot `bin/hubot -a telegram`

## Configuration

This adapter uses the following environment variables:

*TELEGRAM_TOKEN*

Required, the token that the BotFather gives you

*TELEGRAM_WEBHOOK*

Optional, the WebHook of the bot
