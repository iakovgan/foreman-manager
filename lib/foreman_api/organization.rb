module ForemanApi
  class Organization < ForemanApi::Resource
    def initialize args = {}
      args[:path] = "/organizations"
      super args
    end

    def get_id(name)
      begin
        return all(:search => "name=#{name}")["results"].first["id"]
      rescue Exception => e

      end
      return nil
    end

    # gets a list of organizations
    def all(params = {})
      begin
        parse get nil, params
      rescue Exception => e
        []
      end
    end
  end
end
