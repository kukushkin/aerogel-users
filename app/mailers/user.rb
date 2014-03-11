
mailer 'user/email_confirmation' do |user_email|
  user = user_email.user
  url = url_to( "/user/confirm_email",
    fqdn: true,
    email: user_email.email,
    token: user_email.confirmation_token
  )

  to user_email.email
  subject t.aerogel.users.mailers.email_confirmation.subject
  locals full_name: h(user.full_name), url: url
end


mailer 'user/account_activation' do |user|
  user_email = user.emails.first
  url = url_to( "/user/activate_account",
    fqdn: true,
    email: user_email.email,
    token: user_email.confirmation_token
  )

  to user_email.email
  subject t.aerogel.users.mailers.account_activation.subject
  locals full_name: h(user.full_name), url: url
end


mailer 'user/password_reset' do |authentication|
  user_email = authentication.email
  user = user_email.user
  url = url_to( "/user/reset_password",
    fqdn: true,
    email: user_email.email,
    token: authentication.password_reset_token
  )

  user_email = authentication.email
  to user_email.email
  subject t.aerogel.users.mailers.password_reset.subject
  locals full_name: h(user.full_name), url: url
end