def tsend(num, msg)
  tnum = "YOUR_TWILIO_NUMBER"

  Twilio::Config.setup do
    account_sid  = 'YOUR_SID'
    auth_token = 'YOUR_TOKEN'
  end   

  Twilio::SMS.create(:to => num, :from => tnum, :body => msg)
end
