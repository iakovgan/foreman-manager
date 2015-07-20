module ForemanApi
  class Subnet < ForemanApi::Resource
    def initialize args = {}
      args[:path] = "/subnets"
      super args
    end

    # gets a list of subnets
    def all(params = {})
      begin
        parse get nil, params
      rescue Exception => e
        []
      end
    end

    #    def save(params = {})
    #      response = post params
    #      puts response
    #    end

    def find(id)
      begin
        parse get "/#{id}", {}
      rescue Exception => e
        nil
      end
    end
  end
end
