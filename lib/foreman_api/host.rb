module ForemanApi
  class Host < ForemanApi::Resource
    def initialize args = {}
      args[:path] = "/hosts"
      super args
    end

    def get_by_name(name)
      begin
        return all(:search => "name=#{name}")["results"].first
      rescue Exception => e

      end
      return nil
    end

    # gets a list of hosts
    def all(params = {})
      begin
        parse get nil, params
      rescue Exception => e
        []
      end
    end

    def save(params = {})
      begin
        parse post params
      rescue Exception => e
        return  {"error"=>{"id"=>nil, "errors"=>{"exception"=>e.message}, "full_messages"=>e.message}}
      end
    end

    def find(id)
      begin
        parse get "/#{id}", {}
      rescue Exception => e
        nil
      end
    end

    def update(id, params = {})
      begin
        parse put params, "/#{id}"
      rescue Exception => e
        return  {"error"=>{"id"=>nil, "errors"=>{"exception"=>e.message}, "full_messages"=>e.message}}
      end
    end

    def destroy(id)
      begin
        parse delete "/#{id}"
      rescue Exception => e
        nil
      end
    end

		def status(id)
			begin
        parse get "/#{id}/status", {}
      rescue Exception => e
        nil
      end
		end

  end
end
