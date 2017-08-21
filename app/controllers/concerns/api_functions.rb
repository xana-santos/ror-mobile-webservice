module ApiFunctions
  extend ActiveSupport::Concern
  
  private
  
  def schema
    YAML.load_file("#{Rails.root}/app/schemas#{request.path}/#{request.request_method}.fdoc")["requestParameters"] rescue nil
  end
  
  def show_errors(errors, status=400)
   render json: { errors: errors }, status: status and return
  end
  
  # :nocov:
  def pretty_errors(errors)
  
    e = {}

    errors.each do |error|
      message = error.split("in schema")[0]
    
      error_hash = {}
    
      message.gsub!("The property ", "")
      
      keys = message[/#{"'#/"}(.*?)'/m, 1].split("/")
    
      required = message.split("did not contain a required property of '")
      
      main_value = ""
    
      if required.length > 1
        keys << required[1].gsub("'","").strip
        main_value = "is required"
      end
    
      ["of type", "was not of a"].each{|s| main_value = message.split(s)[1].strip if message.include?(s) }
          
      if message.include?("had more items")
        keys << "errors"
        main_value = "Too many items (Max: #{message.split("had more items than the allowed ")[1].strip})"
      end
      
      main_value = "Exceeds maximum value of #{message.scan(/\d+(?:\.\d+)?/).flatten.first}" if message.include?("did not have a maximum value of")
    
      main_value.blank? ? (error_hash = {"other" => message}) : (keys.reverse.inject(main_value) {|value, key| error_hash = {key => value} })
                
      e.deep_merge!(error_hash)
    end

    return e
      
  end
  # :nocov:
  
  def check_schema_errors
    # Check schema exists to check against. Some endpoints won't need request parameters
    puts "in check_schema_errors oioiuoiu"
    if schema
      errors = pretty_errors JSON::Validator.fully_validate(schema, params.except(:controller, :action, :path))
      
      show_errors(errors) or return unless errors.blank?
    end
    
    return true
    
  end
    
  def check_exists(record, method = nil)
    
    mappings = {
      "trainers" => "trainer",
      "gyms" => "gym",
      "clients" => "client",
      "purchases" => "purchase"
    }
    
    controller = controller_name.split("/").last      
    name = method.blank? ? mappings[controller] : method
    
    show_errors("That #{name} does not exist. Please check the ID and try again.") or return if record.blank?
    return true
    
  end
  
  private
  
  def bearer_token
    pattern = /^Bearer /
    header  = request.env["HTTP_AUTHORIZATION"] # <= env
    header.gsub(pattern, '') if header && header.match(pattern)
  end
  
  def authenticate_user  
    unless Authorization.find_by(auth_token: bearer_token)
      case request.format.symbol
      when :html
        render "pages/404" and return
      else
        render json: {error: "Unauthorized. Please check your credentials are correct."}, status: 403 and return
      end
    end
    
  end
  
  # :nocov:
  def show_stripe_error(e)
    
    begin
      body = e.json_body
      err  = body[:error]
    rescue
      err = e
    end
    
    show_errors({stripe_error: err}) or return
    
    return true
    
  end
  # :nocov:
  
end