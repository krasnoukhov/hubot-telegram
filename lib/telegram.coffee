{Robot, Adapter, TextMessage, User} = require 'hubot'
telegrambot = require 'telegrambot'

class Telegram extends Adapter

    constructor: ->
        super

        @token      = process.env['TELEGRAM_TOKEN']
        @webHook    = process.env['TELEGRAM_WEBHOOK']
        @offset     = 0
        @robot.logger.info "Telegram Adapter Bot " + @bot_id + " Loaded..."

        # Get the bot information
        telegrambot.invoke 'getMe', {}, function (err, result) ->
            if (err)
                self.emit 'error', err
            else
                console.log(result)
                @bot_id = result.id

    /**
     * Get the last offset + 1, this will allow
     * the Telegram API to only return new relevant messages
     *
     * @return int
     */
    getLastOffset: ->
        parseInt(@offset) + 1

    send: (envelope, strings...) ->

        #data =
        #    url: "#{@api_url}/sendMessage"
        #    form:
        #        chat_id: envelope.room
        #        text: strings.join()

        #request.post data, (err, res, body) =>
        #    @robot.logger.info res.statusCode

    reply: (envelope, strings...) ->

        #data =
        #    url: "#{@api_url}/sendMessage"
        #    form:
        #        chat_id: envelope.room
        #        text: strings.join()

        #request.post data, (err, res, body) =>
        #    @robot.logger.info res.statusCode

    receiveMsg: (msg) ->

        #user = @robot.brain.userForId msg.message.from.id, name: msg.message.from.username, room: msg.message.chat.id
        #text = msg.message.text

        # Only if it's a text message, not join or leaving events
        #if text
            # If is a direct message to the bot, prepend the name
        #    text = @robot.name + ' ' + msg.message.text if msg.message.chat.id > 0
        #    message = new TextMessage user, text, msg.message_id
        #    @receive message
        #    @offset = msg.update_id

    run: ->
        self = @
        #@robot.logger.info "Run"

        unless @token
            @emit 'error', new Error 'The environment variable "TELEGRAM_TOKEN" is required.'

        #if @webHook
            # Call `setWebHook` to dynamically set the URL
        #    data =
        #        url: "#{@api_url}/setWebHook"
        #        form:
        #            url: @webHook

        #    request.post data, (err, res, body) =>
        #        @robot.logger.info res.statusCode

        #    @robot.router.post "/telegram/receive", (req, res) =>
        #        console.log req.body
        #        for msg in req.body.result
        #            @robot.logger.info "WebHook"
        #            @receiveMsg msg
        #else
        #    setInterval ->
        #        url = "#{self.api_url}/getUpdates?offset=#{self.getLastOffset()}"
        #        self.robot.http(url).get() (err, res, body) ->
        #            self.emit 'error', new Error err if err
        #            updates = JSON.parse body
        #            for msg in updates.result
        #                self.receiveMsg msg
        #    , 2000

        @emit "connected"

exports.use = (robot) ->
    new Telegram robot