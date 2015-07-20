require "foreman/platform/tool/models/host"
require "foreman/platform/tool/models/domain"
require "foreman/platform/tool/models/environment"

module Foreman
	module Platform
		module Tool
			module Models
				class Platform

					attr_accessor :name, :organization, :organization_id, :location, :location_id,
					:compute_resource, :compute_resource_id, :compute_resource_provider, :compute_attributes, 
					:hosts,
					:user_id, :username,
					:domain, :environment

					def initialize(args)
						@user_id = $foreman_settings.user_id
						@username = $foreman_settings.username
						@name = args["environment"]
						@hosts = []
					end

					def initialize_resources(args)
						@organization = args["organization"]
						self.get_organization_id
						@location = args["location"]
						self.get_location_id
						env = @name
						@compute_resource = args["compute_resource"] || args["_basic_host"]["compute_resource"]
						self.get_compute_resource
						args["resources"].each do |resource, resource_params |
							if resource.include?("environment-")
								env_name = eval("\"" + resource_params["name"] + "\"")
								$logger.debug "Initializing environment '#{env_name}'"
								@environment = Foreman::Platform::Models::Environment.new({"name" => env_name, "organization_id" => @organization_id}.merge(resource_params["r10k_reference"].kind_of?(Hash) ? {"git" => resource_params["r10k_reference"]["git"], "branch" => resource_params["r10k_reference"]["branch"]} : {}) )
							elsif resource.include?("domain-")
								domain_name = eval("\"" + resource_params["name"] + "\"")
								$logger.debug "Initializing domain '#{domain_name}'"
								@domain = Foreman::Platform::Models::Domain.new({"name" => domain_name, "subnets" => resource_params["subnets"], "organization_id" => @organization_id})
							end
						end
						raise 'environment-#{env} is required under resources' if @environment.nil?
						raise 'domain-#{env}  is required under resources' if @domain.nil?
						args["resources"].each do |resource, resource_params |

							if resource.include?("host-")

								$logger.debug "---host--"
								resource_params.to_yaml.each_line do |line|
									$logger.debug line
								end

                #rint resource_params.to_yaml
								host_name = resource.sub("host-", "#{@name}-")
								$logger.debug "Initializing host '#{host_name}'"
                
								foreman_compute_attribute = @compute_attributes.select{|compute_attribute| 
                    compute_attribute["compute_profile_name"] == resource_params["compute_profile"]
                }.first 

                if not foreman_compute_attribute
                   raise "Compute profile '#{resource_params["compute_profile"]}' not exist for '#{@compute_resource}' compute resource"
								end

								compute_profile_params =	{
                   "compute_profile" => resource_params["compute_profile"], 
                   "compute_profile_id" => foreman_compute_attribute["compute_profile_id"], 
                   "vm_attrs" => foreman_compute_attribute["vm_attrs"]
                }
								
								config_groups =  []
								if !args["resources"]["_common_host"]["config_groups"].nil? and !args["resources"]["_common_host"]["config_groups"].is_a?(Array)
									raise "Invalid config_groups under _common_host. Must be in array format"
								else
									config_groups = (config_groups + args["resources"]["_common_host"]["config_groups"].to_a)
								end
								if !resource_params["config_groups"].nil? and !resource_params["config_groups"].is_a?(Array)
									raise "Invalid config_groups under #{resource}. Must be in array format"
								else
									config_groups = (config_groups + resource_params["config_groups"].to_a)
								end								
								puppet_classes = []
								if !args["resources"]["_common_host"]["puppet_classes"].nil? and !args["resources"]["_common_host"]["puppet_classes"].is_a?(Array)
									raise "Invalid puppet_classes under _common_host. Must be in array format"
								else
									puppet_classes = (puppet_classes + args["resources"]["_common_host"]["puppet_classes"].to_a)
								end		
								if !resource_params["puppet_classes"].nil? and !resource_params["puppet_classes"].is_a?(Array)
									raise "Invalid puppet_classes under #{resource}. Must be in array format"
								else
									puppet_classes = puppet_classes + resource_params["puppet_classes"].to_a
								end													
								parameters = {}
								if !args["resources"]["_common_host"]["parameters"].nil? and !args["resources"]["_common_host"]["parameters"].is_a?(Hash)
									raise "Invalid parameters under _common_host. Must be key value pairs "
								else
									parameters.merge!(args["resources"]["_common_host"]["parameters"] || {})
								end
								if !resource_params["parameters"].nil? and !resource_params["parameters"].is_a?(Hash)
									raise "Invalid parameters under #{resource}. Must be in array format"
								else
									parameters.merge!(resource_params["parameters"] || {})
								end
								parameters = (args["resources"]["_common_host"]["parameters"] || {}).merge((resource_params["parameters"] || {}))								
								host = Foreman::Platform::Models::Host.new({
									"name" => host_name, "compute_resource" => @compute_resource, "compute_resource_id" => @compute_resource_id, "compute_resource_provider" => @compute_resource_provider,
									"organization" => @organization, "organization_id" => @organization_id, "location" => @location, "location_id" => @location_id, "user_id" => @user_id, "username" => @username,
									"config_groups" => config_groups.uniq, "puppet_classes" => puppet_classes.uniq, "parameters" => parameters, 
									"hostgroup" => resource_params["hostgroup"], "root_password" => args["password"], "ip" => resource_params["ip"], "expiry_on" => args["expiry_on"], 
									"vm_attributes" => resource_params["vm_attributes"], "environment" => @environment.name, "domain" => @domain.name
									}.merge(compute_profile_params))
								host.get_config_groups
								host.get_puppet_class_ids
								if old_host =  @hosts.select{|ohost| ohost.hostgroup.to_s == resource_params["hostgroup"]}.first 
									host.hostgroup_id = old_host.hostgroup_id
									host.host_group_attributes = old_host.host_group_attributes
								else
									host.get_hostgroup_id
								end
								@hosts << host
							elsif resource.include?("vip-")
								#TODO need to implement VIP 
							end
						end
					end

					def get_organization_id
						return @organization_id if @organization_id.to_i != 0
						raise "Organization is required'#{@organization}'" if @organization.to_s.empty?
						$logger.debug "Fetching organization id for '#{@organization}'"
						self.organization_id = ForemanApi::Organization.new.get_id(@organization)
						raise "Invalid Organization '#{@organization}'" if @organization_id.to_i == 0
						return @organization_id
					end

					def get_location_id
						return @location_id if @location_id.to_i != 0 or @location.to_s.empty?
						$logger.debug "Fetching location id for '#{@location}'"
						self.location_id = ForemanApi::Location.new.get_id(@location)
						raise "Invalid location '#{@location}'" if @location_id.to_i == 0
						return @location_id
					end

					def get_compute_resource
						return true if @compute_resource_id.to_i != 0
						$logger.debug "Fetching compute resource '#{@compute_resource}'"
						raise "Compute Resource is required'#{@compute_resource}'" if @compute_resource.to_s.empty?
						foreman_compute_resource = ForemanApi::ComputeResource.new.get_by_name(@compute_resource)

						if foreman_compute_resource and !foreman_compute_resource["id"].nil?
							self.compute_resource_id = foreman_compute_resource["id"]
							self.compute_resource_provider = foreman_compute_resource["provider"].to_s.downcase
							self.compute_attributes = ((ForemanApi::ComputeResource.new.find(@compute_resource_id) || {})["compute_attributes"] || [])
							
						else
							raise "Invalid Compute Resource '#{@compute_resource}'"
						end
						return @compute_resource_id
					end

					def is_environment_exist_in_foreman?
						# @environment = Foreman::Platform::Models::Environment.new({"name" => @name})
						return !@environment.nil? ? @environment.is_exist_in_foreman? : false
					end

					def install
						self.display_changes(false) if @environment.is_exist_in_foreman?
						if @environment.save and @domain.save
							for host in @hosts
								host.environment_id = @environment.id
								host.domain_id = @domain.id
								host.save
							end
							$logger.info "Please check environment in foreman : #{$foreman_settings.url}/hosts/?search=environment=#{@environment.name}"	
						else
							revert
						end
					end

					# def revert
					# 	# puts ""
					# 	# $logger.debug "Reverting platform. Please wait..."

					# 	# for host in @hosts
					# 	# 	host.delete
					# 	# end
					# end

					def platform_foreman_hosts
						$logger.debug "Fetching hosts of '#{@name}' environment"
						foreman_hosts = ForemanApi::Host.new.all(:search => "environment=#{@name}")["results"]
						for foreman_host in foreman_hosts
							host_name = foreman_host["name"].sub(".#{foreman_host["domain_name"]}", "")
							@hosts << host = Foreman::Platform::Models::Host.new({
								"name" => host_name, "compute_resource_provider" => "ovirt", "id" => foreman_host["id"],
								"environment" => @name, "domain" => foreman_host["domain_name"], "organization" => foreman_host["organization_name"]})
						end
						return 	@hosts					
					end

					def delete
						raise "Name is required to delete" if @name.to_s.empty?
						@environment = Foreman::Platform::Models::Environment.new({"name" => @name})
						if @environment.is_exist_in_foreman? and platform_foreman_hosts
							for host in @hosts
								host.delete
							end
							#TODO delete domain
							@environment.delete
						else
							raise "Environment '#{@name}' is not found in foreman"
						end						
					end

					def display_changes(inline=true)
						changes = {"resources" => {}}#{ "environment-#{@name}" => {"branch" => "#{@environment.branch} -> #{@environment.name}"} }}
						for host in @hosts
							changes["resources"].merge!(host.changes)
						end
						return true if !inline
						if !changes["resources"].empty?
							$logger.info "Environment #{@environment.name} is already exist. Please pass 'apply' argument to deploy command to update hosts"
							$logger.stdout changes.to_yaml
						else
							$logger.info "Environment #{@environment.name} is already exist and no changes required"
						end
					end

					def read						
						@environment = Foreman::Platform::Models::Environment.new({"name" => @name})
						if @environment.is_exist_in_foreman? 
							if platform_foreman_hosts and !@hosts.empty?
								properties = {"resources" => { 'environment-#{environment}' => {"name" => '#{environment}'}}}
								for host in @hosts
									properties["resources"].merge!(host.read)
								end
								properties["resources"].merge!({ 'domain-#{environment}' => {"name" => "#{@hosts.first.domain}", "subnets" => ".", "organization" => [@hosts.first.organization]}})
							else
								raise "Environment '#{@name}' does not have hosts in foreman"
							end
						else
							raise "Environment '#{@name}' not found in foreman"
						end
						$logger.stdout properties.to_yaml
					end
						
				end
			end
		end
	end
end
