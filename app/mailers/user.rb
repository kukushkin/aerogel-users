
mailer 'user/email_confirmation' do |user_email|
  to user_email.email
  subject "Activate your account"
  locals user_email: user_email
end