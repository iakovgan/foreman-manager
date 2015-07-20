module ForemanApi
  class Environment < ForemanApi::Resource
    def initialize args = {}
      args[:path] = "/environments"
      super args
    end

    def get_id(name)
      begin
        return all(:search => "name=#{name}")["results"].first["id"]
      rescue Exception => e

      end
      return nil
    end

    # gets a list of environments
    def all(params = {})
      begin
        parse get nil, params
      rescue Exception => e
        []
      end
    end

    def puppet_classes(id)
      begin
        parse get "/#{id}/puppetclasses", {}
      rescue Exception => e
        nil
      end
    end

		def import_puppetclasses(id, smart_proxy_id, params={})
      import_url = "/#{id}/smart_proxies/#{smart_proxy_id}/import_puppetclasses"
      begin
        parse post(params, import_url)
      rescue Exception => e
        return  {"error"=>{"message"=> e.message}}
      end
    end

    def save(params = {})
      begin
        parse(post params)
      rescue Exception => e
        return  {"error"=>{"id"=>nil, "errors"=>{"name"=>e.message}, "full_messages"=>e.message}}
      end
    end

		def destroy(id)
      begin
        parse delete "/#{id}"
      rescue Exception => e
        nil
      end
    end
  
  end
end
