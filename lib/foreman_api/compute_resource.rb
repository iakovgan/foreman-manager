module ForemanApi
  class ComputeResource < ForemanApi::Resource
    def initialize args = {}
      args[:path] = "/compute_resources"
      super args
    end

    def get_by_name(name)
      begin
        return all(:search => "name=#{name}")["results"].first
      rescue Exception => e

      end
      return nil
    end

    # gets a list of host_groups
    def all(params = {})
      begin
        parse get nil, params
      rescue Exception => e
        []
      end
    end 

    def find(id)
      begin
        parse get "/#{id}", {}
      rescue Exception => e
        nil
      end
    end
    
  end
end
