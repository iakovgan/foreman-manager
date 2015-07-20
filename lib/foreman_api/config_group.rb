module ForemanApi
  class ConfigGroup < ForemanApi::Resource
    def initialize args = {}
      args[:path] = "/config_groups"
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

		def config_group_names(names=[])
      return [] if names.to_a.empty?
			return ForemanApi::ConfigGroup.new.all(:search => names.map{|name| "name= "+name.to_s}.join(" or "))["results"]
    end
  end
end