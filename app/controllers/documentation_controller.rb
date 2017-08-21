class DocumentationController < ApplicationController
  http_basic_authenticate_with name: "pflo", password: "pflodocs"

  layout "documentation"

  def show
    @api_endpoint = !Rails.env.development? ? request.protocol + request.host : "#{request.protocol}#{request.host}:#{request.port}"
  end

end
