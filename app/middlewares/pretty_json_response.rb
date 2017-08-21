class PrettyJsonResponse
  
  # :nocov:
  def initialize(app)
    @app = app
  end

  def call(env)
    @status, @headers, @response = @app.call(env)
    [@status, @headers, self]
  end

  def each(&block)
    @response.each do |body|
      if !Rails.env.test? && @headers["Content-Type"] =~ /^application\/json/
        body = add_timestamp(body)
      end
      block.call(body)
    end
  end

  private

  def add_timestamp(json)
    obj = JSON.parse(json)
    obj[:timestamp] = Time.now.to_i
    JSON.unparse(obj)
  end
  # :nocov:

end