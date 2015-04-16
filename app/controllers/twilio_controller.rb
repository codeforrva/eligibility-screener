require 'twilio-ruby'

class TwilioController < ApplicationController

  skip_before_action :verify_authenticity_token

  # these are the words that will be accepted as 'hello'
  # and which locale they will select
  def hello_locales
    {
      "hello" => :en,
      "hi" => :en,
      "hey" => :en,
      "hola" => :es
    }
  end

  # reset words in multiple languages
  # so you can always reset if you get lost
  def reset_words
    %w(reset)
  end

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

      # block to execute with the user's locale
      # setting I18n.locale does not seem to be a good idea
      # because it is thread local and so can leak to other
      # requests in some servers
      I18n.with_locale profile.locale do
        # check for control words
        case body
        when *hello_locales.keys
          profile.locale = hello_locales[body]
          profile.save!
          response = I18n.t('response.welcome', locale: profile.locale)
        when *reset_words
          profile.reset!
          reset_session
          response = I18n.t('response.reset', locale: profile.locale)
        when *I18n.t!('control.delete')
          profile.destroy!
          reset_session
          response = I18n.t('response.delete')
        when *I18n.t!('control.list')
          response = Profile.all_instructions
        when *Profile.screener_names
          profile.active_screener = body
        end

        # send & return if we have response text
        if !response.nil?
          send_text(response)
          return
        end

        # final check to make sure they have selected a screener
        if profile.active_screener.nil?
          send_text I18n.t('response.welcome')
          return
        end

        response = I18n.t(profile.handle_answer!(body))
      end

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
