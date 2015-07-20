module Foreman
	module Platform
		module Providers
			module Libvirt

				# call this method on host object to fetch entire host json to be sent for foreman.
				def get_host_create_json
					return self.common_parameters.merge!(self.base_attributes.merge!(self.compute_attributes))
				end

				def get_host_update_json
					return self.common_parameters.merge(self.host_parameters)
				end
				
				# compute attributes required for Libvirt compute resource
				def compute_attributes
					cp_attributes = self.vm_attrs				
					unless (vm_attributes || {}).empty?						
						cp_attributes["cores"] = vm_attributes["cpus"]
						cp_attributes["memory"] = (vm_attributes["memory_mb"].to_i  * (1024*1024))
						vm_volumes_attributes = cp_attributes["volumes_attributes"]
						vm_volumes_attributes.each{|k, v| k != "new_volumes" ? v["capacity"] = vm_attributes["size_gb"] : ""}
						# vm_volumes_attributes.select{|key, value| key.to_s != "new_volumes"}.first.merge!({"capacity" => vm_attributes["size_gb"]})
						cp_attributes["volumes_attributes"] = vm_volumes_attributes
					end
					return {"compute_attributes" => cp_attributes.merge({"start" => "1"})}
				end
				# base hash attributes which remains common to every providers
				def base_attributes
					# Base Attributes to be sent for foreman host creation API
					{
						"name" 					=> self.name,

						"compute_resource_id" 	=> self.compute_resource_id,

						"compute_profile_id" 	=> self.compute_profile_id,

						"managed"				=> "true",

						"type"					=> "Host::Managed",

						"provision_method"		=> "build",

						"build"					=> "1",

						"disk"					=> "",

						"enabled"				=> "1",

						"model_id"				=> "",

						"comment"				=> "",

						"overwrite" 			=> "false",

						"mac"					=> "",
						"organization_id"		=> self.organization_id,
						"location_id"			=> self.location_id,
						"owner_id"				=> self.user_id,
						"owner_type"			=> "User",
						
					}.merge(self.host_parameters)
				end				
			end
		end
	end
end