require 'net/http'
require 'net/https'
require 'openssl'
require 'uri'

module ForemanApi

  class Resource
    def initialize(args = {})
      raise("Must provide a path a make foreman API") if (args[:path].to_s.empty?)
      @url = $foreman_settings.api_url + args[:path].to_s #+ (!args[:parameters].empty? ? "?"+CGI.unescape(args[:parameters].to_query) : "")
      # Each request is limited to 60 seconds
      @connect_params = {:timeout => 600, :open_timeout => 10, :headers => { :content_type => "application/json", :accept => "application/json" },
                        :user => $foreman_settings.username, :password => $foreman_settings.password, :verify_ssl => OpenSSL::SSL::VERIFY_NONE}

    end

    protected

    

    attr_reader :connect_params, :url

    def make_request(path, http_method, params={})
      
      url = URI.parse(@url+path.to_s)
      http = Net::HTTP.new(url.host, url.port)
      http.open_timeout = @connect_params[:open_timeout] if @connect_params[:open_timeout].to_i > 0
      http.read_timeout = @connect_params[:timeout] if @connect_params[:timeout].to_i > 0
      if @url.include?("https")
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      req = eval("Net::HTTP::#{http_method.capitalize}").new(url.path)
      req.body = params.to_json
      # req.set_form_data(params.to_json)
      req["Accept"] = "application/json"
      req.add_field('Content-Type', 'application/json')
      req.content_type = @connect_params[:headers][:content_type] if !@connect_params[:headers][:content_type].to_s.empty?
      req.basic_auth(@connect_params[:user], @connect_params[:password])
      
      
      # req.content_type = "application/json"
      # puts "curl -k -u '#{@connect_params[:user]}:#{@connect_params[:password]}' -H 'Content-Type:application/json' '#{@url+path.to_s}' -d '#{params.to_json}' -X #{http_method.upcase}"
      response = begin
        http.request(req).body
        # %x[curl -s -k -u '#{@connect_params[:user]}:#{@connect_params[:password]}' -H 'Content-Type:application/json' '#{@url+path.to_s}' -d '#{params.to_json}' -X #{http_method.upcase}]
      rescue Exception => e
        {"errors" => {"general" => e.message}}
      end
    end

    private
    # Decodes the JSON response if no HTTP error has been detected
    # If an HTTP error is received then the error message is saves into @error
    # Returns: Response, if the operation is GET, or true for POST, PUT and DELETE.
    #      OR: false if a HTTP error is detected
    # TODO: add error message handling
    def parse response
      if response #and response.code >= 200 and response.code < 300
        return !response.empty? ? JSON.parse(response) : true
      else
        false
      end
    rescue => e
      $logger.trace "Failed to parse response: #{response} -> #{e}"
      false
    end

    # Perform GET operation on the supplied path
    def get path = "", payload = {}
      make_request(path, "get", payload)
    end

    # Perform POST operation with the supplied payload on the supplied path
    def post payload, path = ""      
      make_request(path, "post", payload)
    end

    # Perform PUT operation with the supplied payload on the supplied path
    def put payload, path = ""
      make_request(path, "put", payload)
    end

    # Perform DELETE operation on the supplied path
    def delete path
      make_request(path, "delete", {})
    end




#     def resource
#       # Required in order to ability to mock the resource
#       @resource ||= RestClient::Resource.new(url, connect_params)
#     end

    
#     private
#     # Decodes the JSON response if no HTTP error has been detected
#     # If an HTTP error is received then the error message is saves into @error
#     # Returns: Response, if the operation is GET, or true for POST, PUT and DELETE.
#     #      OR: false if a HTTP error is detected
#     # TODO: add error message handling
#     def parse response
#       if response #and response.code >= 200 and response.code < 300
#         return !response.body.empty? ? JSON.parse(response.body) : true
#       else
#         false
#       end
#     rescue => e
#       $logger.trace "Failed to parse response: #{response} -> #{e}"
#       false
#     end

#     # Perform GET operation on the supplied path
#     def get path = nil, payload = {}
#       # This ensures that an extra "/" is not generated
#       payload = {:params => payload} unless payload.empty?
#       if path
# #        resource[URI.escape(path)].get(payload || {}){ |response, request, result, &block| response }
# 				resource[URI.escape(path)].get payload
#       else
# #        resource.get (payload || {}) { |response, request, result, &block| response }
# 				resource.get payload
#       end
#     end

#     # Perform POST operation with the supplied payload on the supplied path
#     def post payload, path = ""
#       resource[path].post (payload.to_json) { |response, request, result, &block| response }
#     end

#     # Perform PUT operation with the supplied payload on the supplied path
#     def put payload, path = ""
#       resource[path].put (payload.to_json) { |response, request, result, &block| response }
#     end

#     # Perform DELETE operation on the supplied path
#     def delete path
#       resource[path].delete{ |response, request, result| response }
#     end

  end

end
