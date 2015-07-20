module Foreman
	module Platform
		module Models
			class Domain

				attr_accessor :name, :id, 
							  :subnets, :subnet_ids, :organization, :organization_id


				def initialize(args={})
					args.each do |name, value|
						send("#{name}=", value)
					end
				end

				def is_exist_in_foreman?
					return true if self.id.to_i != 0
					$logger.debug "Checking domain '#{@name}'"
					self.id = ForemanApi::Domain.new.get_id(@name)
					return !self.id.nil?	
				end

				def save
					if !is_exist_in_foreman?
						$logger.debug "Saving domain '#{@name}' in foreman"
						# TODO need to implement domain creation API
						raise "Domain '#{@name}' not eixst in foreman"
						return true
					else
						$logger.info "Domain #{@name} [ "+"Exist".colorize(:green)+" ]"
						return true
					end
				end
				
			end
		end
	end
end