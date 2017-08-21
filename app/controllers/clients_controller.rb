class ClientsController < ApplicationController
  before_filter :get_client
  
  def terms
  end

  def accept_terms
    @client.accept_terms!
    notice = "Terms have successfully been accepted"
    redirect_to session.delete(:return_to), notice: notice and return if session[:return_to]
    redirect_to client_terms_path(@client.api_token), notice: notice
  end
  
  def get_client
    @client = ::Client.find_by(api_token: params[:client_id])
    render_404 if @client.blank?
  end
  
end