class PasswordResetController < ApplicationController
  before_filter :get_user
    
  def edit
        
    if @user.blank?
      flash[:alert] = "Sorry, that password reset token appears to be invalid."
      render "edit"
    end
    
    if @user.reset_sent + 1.days < Date.today
      flash[:alert] = "Sorry, that password reset token has expired."
      render "edit"
    end
    
  end

  def update
    
    @user.force_password_update = true
           
    if @user.update_attributes(user_attributes)
      @user.reset_token = nil
      @user.save
      flash[:notice] = "Password reset successfully!"
      render "success"
    else
      flash[:alert] = "Oops, there were a few errors with your submission. Please check that all fields are filled in correctly and try again."
      render "edit"
    end
    
  end
  
  def get_user
    @user = ::User.find_by(reset_token: params[:reset_token])
    render_404 if @user.blank?
  end
  
  def user_attributes
    params.require(:user).permit(:id, :password, :password_confirmation, :email, :force_password_update)
  end
    
end