module Foreman
	module Platform
		module Providers
			module CommonParameters

				def common_parameters
					{

						"hostgroup_id" 			=> self.hostgroup_id,
						"environment_id"		=> self.environment_id,
						"puppet_ca_proxy_id"	=> self.host_group_attributes["puppet_ca_proxy_id"],
						"puppet_proxy_id"		=> self.host_group_attributes["puppet_proxy_id"],
						"config_group_ids"		=> self.config_group_ids,
						"puppetclass_ids"		=> self.puppet_class_ids,
						"architecture_id"		=> self.host_group_attributes["architecture_id"],
						"operatingsystem_id"	=> self.host_group_attributes["operatingsystem_id"],
						"root_pass"				=> self.root_password,
						"medium_id"				=> self.host_group_attributes["medium_id"],
						"ptable_id"				=> self.host_group_attributes["ptable_id"],
						"domain_id"				=> self.domain_id,
						"realm_id"				=> self.host_group_attributes["realm_id"],						
						"subnet_id"				=> self.host_group_attributes["subnet_id"],

					}.merge(!self.ip.to_s.empty? ? {"ip" => self.ip} : {}).merge(!self.expiry_on.to_s.empty? ? {"expired_on" => self.expiry_on} : {})
				end

				def host_parameters
					count = 0
					
					result = {
						"host_parameters_attributes" => {
						}
					}
					self.parameters.each do |param_name, param_value|
						count += 1
						existing_param = ((@existing_foreman_host_params and @existing_foreman_host_params["parameters"].is_a?(Array)) ? (@existing_foreman_host_params["parameters"].select{|p| p["name"].to_s == param_name.to_s}.first) : nil)
						result["host_parameters_attributes"].merge!(count => {
								"name" => param_name,
								"value" => param_value,
								"_destroy"	=> "false",
								"nested" => "",
								"id" => (existing_param.is_a?(Hash) ? existing_param["id"] : "")
							})
					end
					for existing_host_paramter in @existing_foreman_host_params["parameters"].to_a
						if !result["host_parameters_attributes"].values.map{|par| par["name"].to_s}.include?(existing_host_paramter["name"].to_s)
							count += 1
							result["host_parameters_attributes"].merge!(count => {
								"name" => existing_host_paramter["name"],
								"value" => existing_host_paramter["value"],
								"_destroy"	=> "1",
								"nested" => "",
								"id" => existing_host_paramter["id"]
							})
						end
						
					end
					return result
				end
			end
		end
	end
end
