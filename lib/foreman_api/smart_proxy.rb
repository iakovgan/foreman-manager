module ForemanApi
  class SmartProxy < ForemanApi::Resource
    def initialize args = {}
      args[:path] = "/smart_proxies"
      super args
    end

    # gets a list of smart_proxies
    def all(params = {})
      begin
        parse get nil, params
      rescue Exception => e
        []
      end
    end 

  end
end
