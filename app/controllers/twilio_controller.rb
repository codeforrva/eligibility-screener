require 'twilio-ruby'

class TwilioController < ApplicationController

  skip_before_action :verify_authenticity_token

  def text
    begin
      response = nil
      status = 200

      message = TextMessage.new(params)
      profile = Profile.find_or_create_by!(phone_number: message.From)

      # strip anything after the space and force lowercase
      if message.Body.nil? || message.Body == ''
        render nothing: true
        return
      end
      body = message.Body.split(/ /).first.strip.downcase

      # check for control words
      case body
      when "hello", "hi", "hola"
        # TODO: language selection here?
        response = "Welcome to Aperture Science! We help you check your eligibility for benefits. For a list of programs, text 'list'. You can also text 'reset' or 'delete'."
      when "reset"
        profile.reset!
        reset_session
        response = "OK, reset. Text 'hello' to begin again, or 'list' for a list of programs."
      when "delete"
        profile.destroy!
        reset_session
        response = "OK, info deleted. Text 'hello' to begin again, or 'list' for a list of programs."
      when "list"
        response = RegisteredScreeners.all_instructions
      when *Profile.screener_names
        profile.active_screener = body
      end

      # send & return if we have response text
      if !response.nil?
        send_text(response)
        return
      end

      response = profile.handle_answer!(body)

    rescue Exception => e
      response = 'Error: ' + e.message
      status = 500
      logger.error e.message
      logger.error e.backtrace.join($/)
    end

    send_text(response, status)

  end

private

  def send_text(response, status = 200)
    logger.info "Sending: %s" % response
    twiml = Twilio::TwiML::Response.new do |r|
      r.Message response
    end
    render xml: twiml.text, :status => status
  end

end
