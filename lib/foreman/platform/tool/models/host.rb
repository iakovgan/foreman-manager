require "foreman/platform/tool/providers/common_parameters"
require "foreman/platform/tool/providers/libvirt"
require "foreman/platform/tool/providers/ovirt"
require "foreman/platform/tool/providers/vmware"

module Foreman
	module Platform
		module Models
			class Host

				attr_accessor :name, :id, :user_id, :username, 
							  :organization, :organization_id, :location, :location_id,
							  :compute_resource, :compute_resource_id, :compute_resource_provider, 
							  :config_groups, :config_group_ids, 
							  :puppet_classes, :puppet_class_ids, 
							  :compute_profile, :compute_profile_id, :vm_attrs, :vm_attributes,
							  :hostgroup, :hostgroup_id, :host_group_attributes, :ip, :expiry_on,
							  :environment, :environment_id, 
							  :domain, :domain_id,
							  :parameters, :root_password,
							  :existing_foreman_host_params, :can_update

				def initialize(args={})
					args.each do |name, value|						
						send("#{name}=", value)
					end
					extend  Foreman::Platform::Providers::CommonParameters
					if self.compute_resource_provider == 'ovirt'
						extend Foreman::Platform::Providers::Ovirt
					elsif self.compute_resource_provider == 'libvirt'
						extend  Foreman::Platform::Providers::Libvirt
					elsif self.compute_resource_provider == 'vmware'
						extend  Foreman::Platform::Providers::Vmware
					else
						raise "This tool will not support for #{@compute_resource_provider} compute resource provider"
					end
					# self.get_config_groups
					# self.get_puppet_class_ids
					@existing_foreman_host_params = {}
				end
                                
                                
				def get_hostgroup_id
					return true if hostgroup_id.to_i != 0 
					$logger.debug "Fetching host group '#{@hostgroup}' for #{@name}"
                                        hostgroup_ = @hostgroup.split('/').last
					@host_group_attributes = ForemanApi::HostGroup.new.get_host_group(hostgroup_)
					if @host_group_attributes
						@hostgroup_id = @host_group_attributes["id"]
						return true
					else
						raise "Hostgroup '#{hostgroup_}' not found"
					end
					return false
				end

				def get_config_groups
					$logger.debug "Fetching config groups #{@config_groups.to_json} for #{@name}"			
					foreman_config_group = ForemanApi::ConfigGroup.new.config_group_names(@config_groups)
					if invalid_config_groups = (@config_groups - foreman_config_group.map{|cg| cg["name"]}) and !invalid_config_groups.empty?
						raise "Config groups #{invalid_config_groups.inspect} are invalid"
					end
					@config_group_ids = foreman_config_group.map{|cg| cg["id"]}			
				end

				def get_puppet_class_ids
					$logger.debug "Fetching puppet classes #{@puppet_classes.to_json} for #{@name}"	
					foreman_puppet_classes = ForemanApi::PuppetClass.new.puppet_class_names(@puppet_classes)
					if invalid_puppet_classes = (@puppet_classes - foreman_puppet_classes.map{|cg| cg["name"]}) and !invalid_puppet_classes.empty?
						raise "Puppet classes #{invalid_puppet_classes.inspect} are invalid"
					end
					@puppet_class_ids = foreman_puppet_classes.map{|cg| cg["id"]}			
				end

				def foreman_host_name
					return "#{@name}.#{@domain}"
				end

				def create
					foreman_host_params = self.get_host_create_json
					$logger.debug "Creating host #{@name} in foreman"
					$logger.debug "Host request JSON: #{foreman_host_params.to_yaml}"	
					response_json = ForemanApi::Host.new.save({"host" => foreman_host_params})
					$logger.debug "Host create response JSON: #{response_json.to_json}"	
					if response_json["error"].nil?
						self.id = response_json["id"]						
						$logger.debug "Host #{@name} created with ID #{response_json["id"]} in foreman"
						$logger.info "Host #{@name} [ "+"Created".colorize(:green)+" ]"	
					else
						$logger.debug  "Host creation failed"
						raise "Foreman host creation error: #{response_json["error"].inspect}"
					end
				end

				def update
					foreman_host_params = self.get_host_update_json
					$logger.debug "Updating host #{@name} in foreman"
					$logger.debug "Host request JSON: #{foreman_host_params.to_json}"	
					response_json = ForemanApi::Host.new.update(self.id, {"host" => foreman_host_params})
					$logger.debug "Host update response JSON: #{response_json.to_json}"	
					if response_json["error"].nil?
						self.id = response_json["id"]						
						$logger.debug "Host #{@name} updated with ID #{response_json["id"]} in foreman"
						$logger.info "Host #{@name} [ "+"Updated".colorize(:green)+" ]"	
					else
						$logger.debug  "Host update failed"
						raise "Foreman host update error: #{response_json["error"].inspect}"
					end
				end

				def save
					if is_exist_in_foreman?
						if @can_update
							update
						else
							$logger.info "Host #{@name} [ "+"Nothing to update".colorize(:green)+" ]"	
						end
					else
						create
					end
				end

				def is_exist_in_foreman?
					return true if self.id.to_i != 0 and (!@existing_foreman_host_params.empty?)
					$logger.debug  "Fetching host '#{foreman_host_name}' details "
					@existing_foreman_host_params = ForemanApi::Host.new.find(foreman_host_name)
					if !@existing_foreman_host_params["id"].nil?
						self.id = @existing_foreman_host_params["id"]
						return true
					else
						@existing_foreman_host_params = {}
					end
					return false
				end

				def delete
					return true if self.id.to_i == 0
					$logger.debug "Deleting host #{@name} with ID #{@id} in foreman"
					response_json = ForemanApi::Host.new.destroy(self.id.to_i)
					$logger.debug "Host delete response JSON: #{response_json.to_json}"
					if response_json["error"].nil?
						$logger.info "Host delete #{@name} [ "+"Success".colorize(:green)+" ]"	
					else
						if response_json["error"]["message"].to_s.downcase.include?("host not found")
							$logger.info "Host delete #{@name} [ "+"Not exist in foreman".colorize(:red)+" ]"	
						else
							$logger.info "Host delete #{@name} [ "+"Failed".colorize(:red)+" ]   Please delete manually in foreman"	
						end
					end
				end

				def changes
					blueprint_host_name = name.sub(@environment, "host")
					updates = {
							blueprint_host_name => {

							}
						}
					if is_exist_in_foreman?
						updates[blueprint_host_name].merge!({"compute_profile" => "#{@existing_foreman_host_params["compute_profile_name"]} --> #{@compute_profile}"}) if @compute_profile != @existing_foreman_host_params["compute_profile_name"]
						updates[blueprint_host_name].merge!({"hostgroup" => "#{@existing_foreman_host_params["hostgroup_name"]} --> #{@hostgroup}"}) if @hostgroup != @existing_foreman_host_params["hostgroup_name"]
						# updates[blueprint_host_name].merge!({"environment" => "#{@existing_foreman_host_params["environment_name"]} --> #{@environment}"}) if @environment != @existing_foreman_host_params["environment_name"]
						updates[blueprint_host_name].merge!({"domain" => "#{@existing_foreman_host_params["domain_name"]} --> #{@domain}"}) if @domain != @existing_foreman_host_params["domain_name"]
						updates[blueprint_host_name].merge!({"config_groups" => "[#{@existing_foreman_host_params["config_groups"].map{|cg| "'#{cg["name"]}'"}.join(", ")}] --> [#{@config_groups.map{|cg| "'#{cg}'"}.to_a.join(", ")}]"}) if @config_groups.sort != @existing_foreman_host_params["config_groups"].map{|cg| cg["name"]}.sort
						updates[blueprint_host_name].merge!({"puppet_classes" => "[#{@existing_foreman_host_params["puppetclasses"].map{|pc| "'#{pc["name"]}'"}.join(", ")}] --> [#{@puppet_classes.to_a.map{|pc| "'#{pc}'"}.join(", ")}]"}) if @puppet_classes.sort != @existing_foreman_host_params["puppetclasses"].map{|pc| pc["name"]}.sort
						updates[blueprint_host_name].merge!({"parameters" => "{#{@existing_foreman_host_params["parameters"].collect{|par| "#{par["name"]}: #{par["value"]}"}.join(", ")}} --> {#{@parameters.is_a?(Hash) ? @parameters.map{|k,v| "#{k}: #{v}"}.join(", ") : ""}}"}) if @parameters != Hash[@existing_foreman_host_params["parameters"].collect{|par| [par["name"], par["value"]]}]
						@can_update = true if !updates[blueprint_host_name].empty?
						
					else
						updates[blueprint_host_name].merge!({"compute_profile" => @compute_profile, "hostgroup" => @hostgroup, 
							# "environment" => @environment, "domain" => @domain,
							"config_groups" => @config_groups, "puppet_classes" => @puppet_classes, "parameters" => @parameters
							})
					end
					return (!updates[blueprint_host_name].empty? ? updates : {})
				end

				def read
					blueprint_host_name = name.sub(@environment, "host")
					properties = {
							blueprint_host_name => {

							}
						}
					if is_exist_in_foreman?
						properties[blueprint_host_name].merge!({"compute_profile" => "#{@existing_foreman_host_params["compute_profile_name"]}"})
						properties[blueprint_host_name].merge!({"hostgroup" => "#{@existing_foreman_host_params["hostgroup_name"]}"})
						# properties[blueprint_host_name].merge!({"environment" => "#{@existing_foreman_host_params["environment_name"]} --> #{@environment}"}) if @environment != @existing_foreman_host_params["environment_name"]
						# properties[blueprint_host_name].merge!({"domain" => "#{@existing_foreman_host_params["domain_name"]}"})
						properties[blueprint_host_name].merge!({"config_groups" => @existing_foreman_host_params["config_groups"].map{|cg| "#{cg["name"]}"} })
						properties[blueprint_host_name].merge!({"puppet_classes" => @existing_foreman_host_params["puppetclasses"].map{|pc| "#{pc["name"]}"}})
						properties[blueprint_host_name].merge!({"parameters" => @existing_foreman_host_params["parameters"].inject({}) { |r, i| r[i["name"]] = i["value"]; r }})
						
						
					else
						properties[blueprint_host_name].merge!({})
					end
					return properties
				end
			end
		end
	end
end
