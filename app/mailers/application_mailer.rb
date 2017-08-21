class ApplicationMailer < ActionMailer::Base
  add_template_helper(EmailHelper)
  default from: "no-reply@positivflo.com.au"
  layout 'mailer'
end
