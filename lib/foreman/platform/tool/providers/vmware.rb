
class String
  def skip_nonascii
#       print self
#       self.delete('^a-zA-Z0-9\-')
#       print self 
  end
end

module Foreman
	module Platform
		module Providers
			module  Vmware
				

				# call this method on host object to fetch entire host json to be sent for foreman.
				def get_host_create_json
         
					hash = self.common_parameters.merge!(self.base_attributes.merge!(self.compute_attributes))
 #         hash['compute_attributes']['interfaces_attributes']['new_interfaces']['network'] = "dpg-mgmt"
        #  print hash['compute_attributes']['interfaces_attributes']['new_interfaces'].to_yaml

       #  hash['compute_attributes']['interfaces_attributes']['new_interfaces']['network']  = 
       #   hash['compute_attributes']['interfaces_attributes']['new_interfaces']['network'].gsub!(/[a-]/ , '')
#          print hash.to_yaml
 #         exit()          
          return hash

				end

				def get_host_update_json
					return self.common_parameters.merge(self.host_parameters)
				end

				# compute attributes required for ovirt compute resource
				def compute_attributes
					cp_attributes = self.vm_attrs			
					unless (vm_attributes || {}).empty?
						cp_attributes["cpus"] = vm_attributes["cpus"]
						cp_attributes["memory_mb"] = vm_attributes["memory_mb"].to_i
						vm_volumes_attributes = cp_attributes["volumes_attributes"]
						vm_volumes_attributes.each{|k, v| k != "new_volumes" ? v["size_gb"] = vm_attributes["size_gb"] : ""}
						cp_attributes["volumes_attributes"] = vm_volumes_attributes
					end
					return {"compute_attributes" => cp_attributes.merge({"start" => "1"})}.merge!(self.build_interface)
				end

				# default json snippet required for host creation from foreman.
				def build_interface
					{
						"interfaces_attributes"		=>
							{
							"new_interfaces"		=>
								{
								"_destroy"=>"false",
								"type"=>"Nic::Managed",
								"mac"=>"",
								"identifier"=>"",
								"name"=>"",
								"domain_id"=>"",
								"subnet_id"=>"",
								"ip"=>"",
								"managed"=>"1",
								"virtual"=>"0",
								"tag"=>"",
								"attached_to"=> self.username
							}
						}
					}
 return {}
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
