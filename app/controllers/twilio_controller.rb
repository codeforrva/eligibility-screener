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
      body = message.Body.split(/ /).first.strip.downcase

      # check for control words
      case body
      when "hello", "hi", "hola"
        response = "Welcome to Aperture Science! We help you check your eligibility for benefits. For a list of programs, text 'list'. You can also text 'reset' or 'delete'."
      when "reset"
        profile.reset!
        response = "OK, reset. Text 'hello' to begin again, or 'list' for a list of programs."
      when "delete"
        profile.destroy!
        response = "OK, info deleted. Text 'hello' to begin again, or 'list' for a list of programs."
      when "list"
        # TODO: build a list of program screeners
        response = "For food stamps, text 'food'."
      end
      if !response.nil?
        send_text(response)
        return
      end

      # TODO: choose program to screen for
      # TODO: store which program is active
      # TODO: store which question was asked

      # dummy response
      response = 'You sent: ' + body

    rescue Exception => e
      response = 'Error: ' + e.message
      status = 500
    end

    send_text(response, status)

  end

private

  def send_text(response, status = 200)
    twiml = Twilio::TwiML::Response.new do |r|
      r.Message response
    end
    render xml: twiml.text, :status => status
  end

end
