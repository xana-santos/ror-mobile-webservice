module DocumentationHelper
  
  def get_endpoints(version)
    
    @version = version
    
    html = ""
    
    directories = []
    
    dir_map = {  }
    
    Dir.entries("#{Rails.root}/app/schemas/#{version}").each_with_index do |directory, index| 
      
      next if directory == "." || directory == ".." || directory.starts_with?(".")
      
      directories << directory
      
    end
        
    directories.each do |directory|
      
      title = dir_map[directory] || directory.titleize
      
      full_dir = "#{Rails.root}/app/schemas/v1/#{directory}"
      
      html << "<h1 id='#{directory}' class='section-header'>#{title}</h1>"
      
      if File.exists?("#{full_dir}/#{directory}.fdoc.service")
        info = YAML.load_file("#{full_dir}/#{directory}.fdoc.service")
        html << info["description"] unless info["description"].blank?
      end
      
      @endpoints = []
      
      set_positions("#{full_dir}")
      
      set_subsections_from_endpoints(html)
            
    end
    
    return html
                  
  end
  
  def set_positions(directory)
    
    Dir.glob("#{directory}/*").each do |dir| 
      next if dir == "." || dir == ".." || directory.starts_with?(".")
       
      unless File.directory? dir 
     
        if dir.ends_with? ".fdoc" 
          
          schema = YAML.load_file(dir)
          
          position = schema['docs_position'] || 1000
          
          @endpoints << [position, dir]
          
        end
       
      else
        set_positions(dir)
      end
      
    end
          
  end
  
  def set_subsections_from_endpoints(html)
    
    url_base = "/" + @version
    
    @endpoints.sort_by!{|e| e[0]}.map!{|e| e[1]}
    
    @endpoints.each do |dir|
      
      schema = YAML.load_file(dir)
      title = schema['title']
      description = schema['description']
      filename = dir.split("/").last
      name = description.parameterize
      method = filename.split(".fdoc").first
      path = File.dirname(dir).gsub("#{Rails.root}/app/schemas/#{@version}/", "")
      url = "#{method} #{url_base}/#{path}"
      
      html << "<h2 id='#{name}' class='section-header'>#{title}</h2>"
      
      html << "<pre class='highlight plaintext'><code>#{url}</code></pre>"
      
      unless schema["requestParameters"].blank?
      
        html << '<blockquote><p>Example Request</p></blockquote>'
      
        html << example_request(schema["requestParameters"] || {})
      
      end
      
      html << '<blockquote><p>Example Response</p></blockquote>'
      
      html << example_response(schema["responseParameters"] || {})
            
      html << "#{format_description(description)}"
      
      html << '<h3 id="http-request">HTTP Request</h3>'
      
      html << "<p><code class='prettyprint'>#{url}</code></p>"
      
      if schema['requestParameters']
        properties = schema['requestParameters']['properties']
        required = schema['requestParameters']['required'] || []
        html << arguments_table(properties, required)
      end
      
      if schema['sampleParameters']
        html << sample_table(schema['sampleParameters'])
      end
      
    end
    
  end
  
  def format_description(description)
    description.gsub("[", "<code class='prettyprint'>").gsub("]", "</code>")
  end
  
  ATOMIC_FIELD_TYPES = %w(string integer number boolean null)

  def example_from_schema(schema, items=false)
    
    if schema.nil?
      return nil
    end
    
    type = Array(schema["type"])
        
    if type.any? { |t| ATOMIC_FIELD_TYPES.include?(t) }
      schema["example"] || schema["default"] || example_from_atom(schema)
    elsif type.include?("object") || schema["properties"]
      example_from_object(schema)
    elsif type.include?("array") || schema["items"]
      example_from_array(schema)
    else
      {}
    end  
    
  end

  def example_from_atom(schema, items=false)
    type = Array(schema["type"])
    hash = schema.hash

    if type.include?("boolean")
      [true, false][hash % 2]
    elsif type.include?("integer")
      hash % 1000
    elsif type.include?("number")
      Math.sqrt(hash % 1000).round 2
    elsif type.include?("string")
      nil
    else
      nil
    end
    
  end

  def example_from_object(object)
    example = {}
    if object["properties"]
      examples = object["examples"] || object["required"] || []
      object["properties"].each do |key, value|
        example[key] = example_from_schema(value) if (examples.include?(key) || !@only_examples)
      end
    end
    example
  end

  def example_from_array(array)
    if array["items"].kind_of? Array
      example = []
      array["items"].each do |item|
        example << example_from_schema(item)
      end
      example.reject(&:blank?)
    elsif (array["items"] || {})["type"].kind_of? Array
      example = []
      array["items"]["type"].each do |item|
        example << example_from_schema(item)
      end
      example.reject(&:blank?)
    else
      [example_from_schema(array["items"])].reject(&:blank?)
    end
  end
  
  def example_request(response_parameters)
    @only_examples = true
    to_html(example_from_schema(response_parameters))
  end
  
  def example_response(response_parameters)
    @only_examples = false
    to_html(example_from_schema(response_parameters))
  end
  
  def to_html(json)
    if json.kind_of? String
      '<tt>&quot;%s&quot;</tt>' % json.gsub(/\"/, 'quot;')
    elsif json.kind_of?(Numeric) ||
          json.kind_of?(TrueClass) ||
          json.kind_of?(FalseClass)
      '<tt>%s</tt>' % json
    elsif json.kind_of?(Hash) ||
          json.kind_of?(Array)
      '<div class="codse-block-secondary"><pre class="highlight json"><code>%s</code></pre></div>' % JSON.pretty_generate(json)
    end
  end
  
  def arguments_table(arguments, required)
    
    argument_table = ''
    
    @required = required
    
    unless arguments.blank?
    
      argument_table << '
      <h3 id="arguments">Arguments</h3>
      <table>
        <thead>
          <tr>
            <th>Parameter</th>
            <th>Types</th>
            <th>Required</th>
            <th>Description</th>
          </tr>
        </thead>
        <tbody>'
      
      set_arguments("", arguments, argument_table, required)
      
      argument_table << '</tbody></table>'
      
    end
    
    return argument_table
    
  end
  
  def set_arguments(value="", arguments=[], argument_table="", required=[], pre="", original="")
      
    required_attrs = required.map{|r| "#{value}_#{r}" }
    
    @required << required_attrs
    
    full_required = @required.flatten rescue []
                    
    arguments.each do |argument, values|
      
      full_value = "#{value}_#{argument}"
      
      is_required = (full_required.include?(full_value))
              
      type = ((values['type'].is_a? Array) ? values['type'].join(", ") : values['type'])
      name = pre.blank? ? argument : "#{pre}[#{argument}]"
      object = type == "object"
      level = pre.include?("[]") ? pre.split("[").length - 1 : pre.split("[").length
      
      argument_table << "<tr data-nested='#{name.parameterize}'>" if pre.blank?
      argument_table << "<tr class='hidden nested-#{level} nested-#{pre.parameterize}' data-name=#{name.parameterize}>" unless pre.blank?
      
      description = values['description'] || ""
      minimum = values['minimum']
      maximum = values['maximum']
      default = values['default']
      
      full_description = [description]
      full_description << "Minimum is #{minimum}" unless minimum.blank?
      full_description << "Maximum is #{maximum}" unless maximum.blank?
      full_description << "Default is #{default}" unless default.nil?
      
      full_description = full_description.reject(&:blank?).join(". ")
      full_description += "." unless full_description.blank?
      
      if type == "array"
        name += "[]"
        
        items = values['items']
        
        if items['type'] != "object"
          set_enum(full_description, items['enum']) if items['enum']
        end
              
      end
        
      set_enum(full_description, values['enum']) if values['enum']
      
      object_array = type == "array" && (values['items']['type'] == "object" rescue false)
      has_attributes = (type == 'object' || object_array)
      
      if has_attributes
        argument_table << 
        "<td class='object'>#{name} <br /> 
          <span class='expand-link'>Show Attributes [+]</span>
          <span class='collapse-link'>Hide Attributes [-]</span>
        </td>"
      else
        argument_table << "<td>#{name}</td>"
      end
      
      argument_table << "<td>#{type}</td>"
      argument_table << "<td>#{is_required}</td>"
      argument_table << "<td>#{(format_description(full_description.squish) rescue nil)}</td>"
      argument_table << '</tr>'
      
      if type == "object"
        properties = values['properties']
        required = values['required'] || []
        set_attributes(full_value, values['properties'], argument_table, required, pre, name)
      end
      
      if object_array
        properties = values['items']['properties']
        required = values['items']['required'] || []
        set_attributes(full_value, values['items']['properties'], argument_table, required, pre, name)
      end
      
    end
    
  end
  
  def set_attributes(value, properties, argument_table, required, pre, name)
    original = pre
    set_arguments(value, properties, argument_table, required, pre=name, original) if properties
    pre = original
  end
  
  def set_enum(description, enums)
    
    description << " Valid values are "
    
    enums.each_with_index do |enum, index|
      value = (enum.kind_of? String) ? "'#{enum}'" : enum
      description << "#{!index.zero? and ', ' or ''}<code class='prettyprint'>#{value}</code>"
    end
    
  end
  
  def sample_table(samples)
    
    samples_table = ""
    
    unless samples.blank?
    
      samples_table << '
      <h3 class="sandbox">Sandbox Parameters</h3>
      <table class="sandbox">
        <thead>
          <tr>
            <th>Parameter</th>
            <th>Value</th>
            <th>Result</th>
          </tr>
        </thead>
        <tbody>'
      
      samples.each do |sample, properties|
        properties['values'].each do |value|
          samples_table << "<tr>"
          samples_table << "<td>#{sample}</td>"
          samples_table << "<td>#{value['value']}</td>"
          samples_table << "<td>#{value['result']}.</td>"
          samples_table << "</tr>"
        end
      end
      
      samples_table << '</tbody></table>'
      
    end
    
    return samples_table
    
  end
  
end