module ForemanApi
  class Domain < ForemanApi::Resource
    def initialize args = {}
      args[:path] = "/domains"
      super args
    end

    def get_id(name)
      begin
        return all(:search => "name=#{name}")["results"].first["id"]
      rescue Exception => e

      end
      return nil
    end

    # gets a list of domains
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
