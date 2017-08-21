class ClientSessionsController < ApplicationController
  before_filter :get_client_session

  def show
    @client = @client_session.client

    unless @client.terms_accepted
      set_return_to
      redirect_to client_terms_path(@client.api_token), alert: "You must accept these terms and conditions before you can confirm this session."
    end
  end

  def confirm
    @client_session.confirm!
    redirect_to session_path(@client_session.api_token), notice: "Session has successfully been confirmed"
  end

  def reject
    @client_session.reject!
    redirect_to session_path(@client_session.api_token), notice: "Session has successfully been rejected"
  end

  private

  def get_client_session
    @client_session = ::ClientSession.find_by(api_token: (params[:session_id] || params[:id]))
    render_404 if @client_session.blank?
  end

end
