module ForemanApi
  class Location < ForemanApi::Resource
    def initialize args = {}
      args[:path] = "/locations"
      super args
    end

    def get_id(name)
      begin
        return all(:search => "name=#{name}")["results"].first["id"]
      rescue Exception => e

      end
      return nil
    end

    # gets a list of locations
    def all(params = {})
      begin
        parse get nil, params
      rescue Exception => e
        []
      end
    end
  end
end
