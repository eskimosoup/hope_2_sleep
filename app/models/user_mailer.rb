class UserMailer < ActionMailer::Base
	
	add_template_helper ApplicationHelper
	
	def password_reset_instructions(user)  
    @subject                        = "Password Reset Instructions"  
    @from                           = SiteSetting.like("Email").first.value  
    @recipients                     = user.email  
    @body[:edit_password_reset_url] = edit_user_password_reset_url(user.perishable_token)  
    content_type "text/html"  
  end  
    
end
