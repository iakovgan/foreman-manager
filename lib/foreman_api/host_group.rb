module ForemanApi
  class HostGroup < ForemanApi::Resource
    def initialize args = {}
      args[:path] = "/hostgroups"
      super args
    end

    # gets a list of host_groups
    def all(params = {})
      begin
        parse get nil, params
      rescue Exception => e
        []
      end
    end

    def get_host_group(name="")
      return nil if name.empty?
      hostgroup = ForemanApi::HostGroup.new.all(:search => "name=#{name}")
      (hostgroup and hostgroup["results"]) ? hostgroup["results"].last : nil
    end

  end
end
