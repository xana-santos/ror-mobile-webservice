class ApiController < ApplicationController
  include ApiFunctions
  protect_from_forgery with: :null_session
  skip_before_filter :verify_authenticity_token
  before_filter :authenticate_user
  before_filter :check_schema_errors
  
  # :nocov:
  def routing_error
    raise ActionController::RoutingError.new(params[:path])
  end
  
  private

  def render_404
    render "pages/404" and return if request.format.symbol == :html
    render json: { errors: "The method you were looking for does not exist."}, status: 404 and return
    true
  end
  
  unless Rails.env.development? || Rails.env.test?
    rescue_from Exception do |e|
      render_500(e)
    end
  end
  
  rescue_from ActionController::RoutingError, with: :render_404
  
  def render_500(e)
    puts e.message
    puts e.backtrace
    Delayed::Job.enqueue EmailErrorJob.new(e.message, e.backtrace, {method: request.method, path: request.path, body: request.body.read}), queue: "error_message"
    render json: { errors: "We're sorry, but something went wrong. We've been notified about this issue and we'll take a look at it shortly." }, status: 500 and return
    true
  end
  
  # :nocov:
    
end
