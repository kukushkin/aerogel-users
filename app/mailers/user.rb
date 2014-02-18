
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


mailer 'user/password_reset' do |authentication|
  user_email = authentication.email
  to user_email.email
  subject "Reset your password"
  locals user_email: user_email, authentication: authentication
end