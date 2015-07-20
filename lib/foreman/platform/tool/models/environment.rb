require "r10k/git/remote"
require 'tmpdir'
require 'date'
require 'fileutils'
module Foreman
	module Platform
		module Models
			class Environment

				attr_accessor :name, :id, 
				:git, :branch, :organization_id


				def initialize(args={})
					args.each do |name, value|
						send("#{name}=", value)
					end
				end

				def is_exist_in_foreman?
					return true if self.id.to_i != 0
					$logger.debug "Checking environment '#{@name}' in foreman"
					self.id = ForemanApi::Environment.new.get_id(@name)
					return !self.id.nil?					
				end

				def save(attempt = 0)
					return true if !self.id.nil?
					if !is_exist_in_foreman?
						$logger.debug "Environment '#{@name}' not found in foreman"
						return create_foreman_environment(attempt)
					else
						$logger.info "Environment #{@name} [ "+"Exist".colorize(:green)+" ]"
						$logger.debug "Found environment '#{@name}' in foreman"
						return true
					end
				end

				def create_foreman_environment(attempt = 0)
					attempt += 1
					if create_git_branch
						$logger.debug "Creating environment '#{@name}' in foreman"
						foreman_environment = ForemanApi::Environment.new.save(:environment => {:name => @name, :organization_ids => [@organization_id]})
				        if foreman_environment["error"].nil?
				          $logger.debug "Created environment '#{@name}' in foreman with id #{foreman_environment["id"]}"
				          $logger.info "Environment #{@name} [ "+"Created".colorize(:green)+" ]"
				          self.id = foreman_environment["id"]
				          import_puppetclasses
				          return true
				        else
				          $logger.debug "Foreman environment error: #{foreman_environment["error"].inspect}"
				          $logger.debug "Failed to create environment in foreman. #{attempt < 6 ? "Doing again." : "" }"
				          self.save(attempt) if attempt < 6
				          raise "Failed to create environment in foreman"
				        end
				    else
				    	self.create_foreman_environment(attempt) if attempt < 6
				    	raise "Failed to create branch in #{@git.inspect}"
					end
					
				end

				def import_puppetclasses
					$logger.debug "Importing puppet classes to foreman environment"
					begin
						smart_proxies = ForemanApi::SmartProxy.new.all(:search => 'feature="Puppet CA"')["results"]						
						for smart_proxy in smart_proxies
							ForemanApi::Environment.new.import_puppetclasses(self.id, smart_proxy["id"])						
						end
					rescue Exception => e
						
					end
				end

				def create_git_branch
					return true # TODO This has been removed for temporary
					remotes = if @git.is_a? String
						[@git]
					elsif @git.is_a? Array
						@git
					else
						[]
					end
					new_branch_status = false
					for remote in remotes
						git_repository = R10K::Git::Remote.new(remote, @branch, checkout_path)
						$logger.debug "Creating branch '#{@name}' in '#{remote}' repository"
						new_branch_status = git_repository.create_new_remote_branch(@name)
						git_repository.delete_clone_dir
						if new_branch_status
							$logger.debug "Created branch '#{@name}' in '#{remote}'"
						else							
							$logger.debug "Failed to create branch '#{@name}' in '#{remote}'"
							break
						end						
					end
					return new_branch_status
					
				end

				def checkout_path
					git_clone_dir = File.join(Dir::tmpdir, "foreman_platform_tool#{(rand() * 10000).to_i}", @name)
				end

				def delete
					if is_exist_in_foreman?
						$logger.debug "Found environment '#{@name}' in foreman with #{self.id}"
						$logger.debug "Deleting environment '#{@name}' in foreman with id #{foreman_environment["id"]}"
						foreman_environment = ForemanApi::Environment.new.destroy(self.id)
						$logger.debug "Foreman response: #{foreman_environment.inspect}"
				        if foreman_environment["error"].nil?				          
				          $logger.info "Environment #{@name} [ "+"Deleted".colorize(:green)+" ]"
				          return true
				        elsif foreman_environment["error"]["message"].include?("environment not found")
				        	$logger.info "Environment #{@name} [ "+"Already Deleted".colorize(:green)+" ]"
				        else
				          $logger.debug "Foreman environment error: #{foreman_environment["error"].inspect}"
				          raise "Failed to delete environment in foreman"
				        end						
					else
						$logger.debug "Environment '#{@name}' not found in foreman"
						return true
					end
				end
			end
		end
	end
end

