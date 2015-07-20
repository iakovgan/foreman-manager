module ForemanApi
  class User < ForemanApi::Resource
    def initialize args = {}
      args[:path] = "/users"
      super args
    end

    def get_id(login)
      begin
        return all(:search => "login=#{login}")["results"].first["id"]
      rescue Exception => e

      end
      return nil
    end


    # gets a list of users
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

    def update(id,params)
      begin
        parse put params, "/#{id}"
      rescue Exception => e
        return  {"error"=>{"id"=>id, "errors"=>{"exception"=>e.message}, "full_messages"=>e.message}}
      end
    end

    def destroy(id)
      begin
        parse delete "/#{id}"
      rescue Exception => e
        return  {"error"=> {"message"=>e.message, "full_messages"=>e.message}}
      end
    end

  end
end
