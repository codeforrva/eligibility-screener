require 'twilio-ruby'

class TwilioController < ApplicationController

  def text

  session["counter"] ||= 0

  # check here to see if a signature is included on the text message
  if params[:Body].strip.match(" ")
    params[:Body] = params[:Body].split(/ /).first
  end

  # if the user wants to start from the beginning
  if params[:Body].strip.downcase == "reset"
    session["counter"] = 0
  end

  # User texts hello to begin the pre-screening process
  if params[:Body].strip.downcase == "hello" || params[:Body].strip.downcase == "hi" || params[:Body].strip.downcase == "hola"
    session["counter"] = 0
  end

  if session["counter"] == 0
   message = "Welcome to mRelief! We help you check your eligibility for benefits. For foodstamps, text 'food'. If you make a mistake, send the message 'reset'."
  end

  if params[:Body].strip.downcase == "food"
     message = "Are you enrolled in a college or institution of higher education? Enter 'yes' or 'no'"
     session["page"] = "snap_college_question"
     session["counter"] = 1
  end


   # HERE IS THE FOOD STAMPS LOGIC
   if session["page"] == "snap_college_question" && session["counter"] == 2

    session["college"] = params[:Body].strip.downcase
     if session["college"] == "no"
       message = "Are you a citizen of the United States? Enter 'yes' or 'no'"
       session["page"] = "snap_citizen_question"
     elsif session["college"] == "yes"
       # if the user is in school, mRelief refers them to a paralegal
       message = "What is your zipcode?"
       session["page"] = "snap_zipcode_question"
      else
        message = "Oops looks like there is a typo! Please type 'yes' or 'no' to answer this question."
        session["counter"] = 1
     end
   end

   if session["page"] == "snap_citizen_question" && session["counter"] == 3
    if session["citizen"]  == "no"
       # if the user is not a citizen, mRelief refers them to a paralegal
       message = "What is your zipcode?"
       session["page"] = "snap_eligible_maybe"
     elsif session["citizen"]  == "yes"
       message = "How old are you? Enter a number"
       session["page"] = "snap_age_question"
     else
      message = "Oops looks like there is a typo! Please type 'yes' or 'no' to answer this question."
       session["counter"] = 2
     end
   end

   if session["page"] == "snap_age_question" && session["counter"] == 4
     session["age"] = params[:Body].strip
     if session["age"] >= 18
      message = "What is the number of people living in your household including yourself? Enter a number"
      session["page"] = "snap_household_question"
     else
      message = "What is your zipcode?"
      session["page"] = "snap_ineligible"
    end
   end

   if session["page"] == "snap_household_question" && session["counter"] == 5
     session["dependents"] = params[:Body].strip
     message = "What is your zipcode?"
     session["page"] = "snap_zipcode_question"
   end

   if session["page"] == "snap_zipcode_question" && session["counter"] == 6
     session["zipcode"] = params[:Body].strip
     message = "Are you disabled? Enter 'yes' or 'no'"
     session["page"] = "snap_disability_question"
   end

   if session["page"] == "snap_disability_question" && session["counter"] == 7
      session["disability"] = params[:Body].strip.downcase
     if session["disability"]  == "no"
       message = "What is the gross monthly income of all people living in your household including yourself? Income includes social security, child support, and unemployment insurance before any deductions. Enter a number. Example - 1000."
       session["page"] = "snap_income_question"
     elsif session["disability"]  == "yes"
       message = "Are you receiving disability payments from from Social Security, the Railroad Retirement Board or Veterans Affairs? Enter 'yes' or 'no'"
       session["page"] = "snap_disability_payment"
     else
      message = "Oops looks like there is a typo! Please type 'yes' or 'no' to answer this question."
      session["counter"] = 6
    end
   end

   # if the user is disabled
   if session["page"] == "snap_disability_payment" && session["counter"] == 8
     session["disability_payment"] = params[:Body].strip
     message = "What is the gross monthly income of all people living in your household including yourself? Income includes social security, child support, and unemployment insurance before any deductions. Enter a number. Example - 1000."
     if session["disability_payment"] == "yes"
      @disability
     elsif session["disability_payment"] == "no"
     else
      message = "Oops looks like there is a typo! Please type 'yes' or 'no' to answer this question."
      session["counter"] = 7
     end
     session["page"] = "snap_income_question_disability"
   end

   # if the user is not disabled
   if session["page"] == "snap_income_question" && session["counter"] == 8
     session["income"] = params[:Body].strip

     age = session["age"].to_i
     snap_dependent_no = session["dependents"].to_i
     snap_gross_income = session["income"].to_i
      if age <= 59
        snap_eligibility = SnapEligibility.find_by({ :snap_dependent_no => snap_dependent_no }) #the cutoffs for Illinois are stored in our seeds file
      else
        snap_eligibility = SnapEligibilitySenior.find_by({ :snap_dependent_no => snap_dependent_no })
      end

      if snap_gross_income < snap_eligibility.snap_gross_income
        message = "You may be in luck! You likely qualify for foodstamps. To access your food stamps, go to #{@lafcenter.center} at #{@lafcenter.address} #{@lafcenter.city}, #{@lafcenter.zipcode.to_i }, #{@lafcenter.telephone}. "
      else
        message = "Based on your household size and income, you likely do not qualify for food stamps. To access additional resources, please call 211. "
      end
   end

   if session["page"] == "snap_income_question_disability" && session["counter"] == 9
     session["income"] = params[:Body].strip
     snap_dependent_no = session["dependents"].to_i
     snap_gross_income = session["income"].to_i
     age = session["age"].to_i
      if @disability.present?
        snap_eligibility = SnapEligibilitySenior.find_by({ :snap_dependent_no => snap_dependent_no })
      else
        snap_eligibility = SnapEligibility.find_by({ :snap_dependent_no => snap_dependent_no })
      end

      if snap_gross_income < snap_eligibility.snap_gross_income
        message = "You may be in luck! You likely qualify for foodstamps. To access your food stamps, go to #{@lafcenter.center} at #{@lafcenter.address} #{@lafcenter.city}, #{@lafcenter.zipcode.to_i }, #{@lafcenter.telephone}. "
      else
        message = "Based on your household size and income, you likely do not qualify for food stamps. To access additional resources, please call 211. "
      end
   end

   # Food stamps user is in school, we refer them to a LAF center
   if session["page"] == "snap_zipcode_question" && session["counter"] == 3
    session["zipcode"] = params[:Body].strip
     user_zipcode = session["zipcode"]
     @zipcode = user_zipcode << ".0"
     @lafcenter = LafCenter.find_by(:zipcode => @zipcode)
     if @lafcenter.present?
     else
       @lafcenter = LafCenter.find_by(:id => 10)
     end
     message = "We cannot determine your eligibility at this time. To discuss your situation with a Food Stamp expert, go to the LAF #{@lafcenter.center} at #{@lafcenter.address} #{@lafcenter.city}, #{@lafcenter.zipcode.to_i } or call #{@lafcenter.telephone}."
   end

   # Food stamps user is not a US citizen, we refer them to a LAF center
   if session["page"] == "snap_eligible_maybe" && session["counter"] == 4
    session["zipcode"] = params[:Body].strip
     user_zipcode = session["zipcode"]
     @zipcode = user_zipcode << ".0"
     @lafcenter = LafCenter.find_by(:zipcode => @zipcode)
     if @lafcenter.present?
     else
       @lafcenter = LafCenter.find_by(:id => 10)
     end
     message = "We cannot determine your eligibility at this time. To discuss your situation with a Food Stamp expert, go to the LAF #{@lafcenter.center} at #{@lafcenter.address} #{@lafcenter.city}, #{@lafcenter.zipcode.to_i } or call #{@lafcenter.telephone}."
   end

   # Food stamps user is younger than 18
   if session["page"] == "snap_ineligible" && session["counter"] == 5
    user_zipcode = session["zipcode"]
    message = "Based on your age, you likely do not qualify for food stamps. A food pantry near you is #{@food_pantry.name} - #{@food_pantry.street} #{@food_pantry.city} #{@food_pantry.state}, #{@food_pantry.zip} #{@food_pantry.phone}."
    @s.snap_eligibility_status = "no"
    @s.completed = true
    @s.save
   end

   twiml = Twilio::TwiML::Response.new do |r|
       r.Message message
   end
    session["counter"] += 1

    respond_to do |format|
     format.xml {render xml: twiml.text}
   end
  end

#  include Webhookable

#   after_filter :set_header

   skip_before_action :verify_authenticity_token


end
