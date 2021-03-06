{Robot, Adapter, TextMessage, User} = require 'hubot'
request = require 'request'

class Telegram extends Adapter

  constructor: ->
    super
    @robot.logger.info "Telegram Adapter loaded"

    @token = process.env['TELEGRAM_TOKEN']
    @webHook = process.env['TELEGRAM_WEBHOOK']
    @debug = process.env['TELEGRAM_DEBUG']
    @api_url = "https://api.telegram.org/bot#{@token}"
    @offset = 0

    # Get the Bot Id and name...not used by now
    request "#{@api_url}/getMe", (err, res, body) =>
      @id = JSON.parse(body).result.id if res.statusCode == 200

  send: (envelope, strings...) ->

    data =
      url: "#{@api_url}/sendMessage"
      form:
        chat_id: envelope.room
        text: strings.join()

    @robot.logger.info "Send:", data if @debug

    request.post data, (err, res, body) =>
      @robot.logger.info res.statusCode

  reply: (envelope, strings...) ->

    data =
      url: "#{@api_url}/sendMessage"
      form:
        chat_id: envelope.room
        text: strings.join()

    @robot.logger.info "Reply:", data if @debug

    request.post data, (err, res, body) =>
      @robot.logger.info res.statusCode

  receiveMsg: (msg) ->
    @robot.logger.info "Receive:", msg if @debug

    message = msg.message || msg.edited_message
    user = @robot.brain.userForId message.from.id, name: message.from.username, room: message.chat.id
    text = message.text

    # Only if it's a text message, not join or leaving events
    if text
      # If is a direct message to the bot, prepend the name
      text = @robot.name + ' ' + message.text if message.chat.id > 0
      message = new TextMessage user, text, message.message_id
      @receive message
      @offset = msg.update_id

  getLastOffset: ->
    # Increment the last offset
    parseInt(@offset) + 1

  run: ->
    self = @
    @robot.logger.info "Run"

    unless @token
      @emit 'error', new Error `'The environment variable \`\033[31mTELEGRAM_TOKEN\033[39m\` is required.'`

    if @webHook
      # Call `setWebHook` to dynamically set the URL
      data =
        url: "#{@api_url}/setWebHook"
        form:
          url: @webHook

      request.post data, (err, res, body) =>
        @robot.logger.info res.statusCode

      @robot.router.post "/telegram/receive", (req, res) =>
        try
          if typeof req.body is "array"
            for msg in req.body
              @receiveMsg msg
          else
            @receiveMsg req.body
        catch error
          @robot.logger.error "Error: #{error}"
          @robot.logger.info req.body
    else
      setInterval ->
        url = "#{self.api_url}/getUpdates?offset=#{self.getLastOffset()}"
        self.robot.http(url).get() (err, res, body) ->
          self.emit 'error', new Error err if err
          updates = JSON.parse body
          for msg in updates.result
            self.receiveMsg msg
      , 2000

    @emit "connected"

exports.use = (robot) ->
  new Telegram robot
