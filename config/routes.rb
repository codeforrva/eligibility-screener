Rails.application.routes.draw do

  get('/', { :controller => 'home', :action => 'index' })
  get("/twilio", { :controller => "send_text", :action => "send_text_message"})
  post('/', { :controller => 'twilio', :action => 'text'})

end
