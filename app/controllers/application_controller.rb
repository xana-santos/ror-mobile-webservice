class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  def routing_error
    raise ActionController::RoutingError.new(params[:path])
  end
  
  private

  def render_404
    render "pages/404"
  end
  
  def set_return_to
    session[:return_to] = request.path
  end
  
end
