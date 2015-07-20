module ForemanApi
  class PuppetClass < ForemanApi::Resource
    def initialize args = {}
      args[:path] = "/puppetclasses"
      super args
    end

    # gets a list of config groups
    def all(params = {})
      begin
        parse get nil, params
      rescue Exception => e
        []
      end
    end

    def puppet_class_names(names=[])
      return [] if names.to_a.empty?
			return ForemanApi::PuppetClass.new.all(:search => names.map{|name| "name= "+name.to_s}.join(" or "))["results"].values.flatten
    end

  end
end