
mailer 'user/email_confirmation' do |user_email|
  to user_email.email
  subject "Confirm your email address"
  locals user_email: user_email
end


mailer 'user/account_activation' do |user|
  user_email = user.emails.first
  to user_email.email
  subject "Activate your account"
  locals user_email: user_email
end