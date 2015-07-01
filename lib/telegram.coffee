{Robot, Adapter, TextMessage, User} = require 'hubot'
telegrambot = require 'telegrambot'

class Telegram extends Adapter

    constructor: ->
        super
        self = @

        @token      = process.env['TELEGRAM_TOKEN']
        @web_hook   = process.env['TELEGRAM_WEBHOOK']
        @privacy    = process.env['TELEGRAM_PRIVACY']
        @interval   = process.env['TELEGRAM_INTERVAL'] || 2000
        @offset     = 0
        @api        = new telegrambot(@token)

        @robot.logger.info "Telegram Adapter Bot " + @token + " Loaded..."

        # Get the bot information
        @api.invoke 'getMe', {}, (err, result) ->
            if (err)
                self.emit 'error', err
            else
                self.bot_id = result.id
                self.bot_username = result.username
                self.bot_firstname = result.first_name
                self.robot.logger.info "Telegram Bot Identified: " + self.bot_firstname

    ###*
    # Get the last offset + 1, this will allow
    # the Telegram API to only return new relevant messages
    #
    # @return int
    ###
    getLastOffset: ->
        parseInt(@offset) + 1

    ###*
    # Send a message to a specific room via the Telegram API
    ###
    send: (envelope, strings...) ->
        self = @

        @api.invoke 'sendMessage', { chat_id: envelope.room, text: strings.join() }, (err, message) =>

            if (err)
                self.emit 'error', err
            else
                self.robot.logger.info "Sending message to room: " + envelope.room

    ###*
    # The only difference between send() and reply() is that we add the "reply_to_message_id" parameter when
    # calling the API
    ###
    reply: (envelope, strings...) ->
        self = @

        @telegram.invoke 'sendMessage', { chat_id: envelope.room, text: strings.join(), reply_to_message_id: envelope.message.id }, (err, message) =>

            if (err)
                self.emit 'error', err
            else
                self.robot.logger.info "Reply message to room/message: " + envelope.room + "/" + envelope.id

    ###*
    # "Private" method to handle a new update received via a webhook
    # or poll update.
    ###
    handleUpdate: (update) ->

        message = update.message
        @robot.logger.info "Receiving message_id: " + message.message_id

        # Only if it's a text message, not join or leaving events
        # TODO: handle join/leave events
        if (typeof message.text != 'undefined')
            text = message.text

            # If we are running in privacy mode, strip out the stuff we don't need.
            if (@privacy)
                text = text.replace(/^\//g, '')
                text = text.replace(new RegExp('@' + @bot_username + '', 'g'), '')

            @robot.logger.debug "Received message: " + message.from.username + " said '" + text + "'"

            # TODO: use the brain?
            user = new User message.from.id, name: message.from.username, room: message.chat.id
            @receive new TextMessage user, text, message.message_id

        # Increment the current offset
        @offset = update.update_id

    run: ->
        self = @

        unless @token
            @emit 'error', new Error 'The environment variable "TELEGRAM_TOKEN" is required.'

        if @web_hook

            @api.invoke 'setWebHook', { url: @web_hook }, (err, result) ->
                if (err)
                    self.emit 'error', err

            @robot.router.post "/hubot/telegram/receive", (req, res) =>
                for msg in req.body.result
                    self.handleUpdate msg

        else
            setInterval ->

                self.api.invoke 'getUpdates', { offset: self.getLastOffset(), limit: 10 }, (err, result) ->

                    if (err)
                        self.emit 'error', err
                    else
                        for msg in result
                            self.handleUpdate msg

            , @interval

        @robot.logger.info "Telegram Adapter Started..."
        @emit "connected"

exports.use = (robot) ->
    new Telegram robot