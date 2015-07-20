require "foreman/platform/tool/cli/version"
require "foreman_api"
require "foreman/platform/tool/platform"

module ForemanPlatformTool
  class Command

  		def method_missing(method, *args, &block)
  			$logger.error "Command '#{method.to_s.gsub("_help", "")}' not found"
  		end

		def help
			puts "Foreman Platform Tool Cli: This gem will manage platforms using Foreman API"
			puts "Version: #{Foreman::Platform::Tool::Cli::VERSION}"
			puts "List of commands:"
			puts "$> foreman-platform-tool read".colorize(:yellow)
			puts "  To know more about 'read' command, use help command with 'read'. Ex: $> foreman-platform-tool help read "
			puts "$> foreman-platform-tool apply".colorize(:yellow)
			puts "  To know more about 'apply' command, use help command with 'apply'. Ex: $> foreman-platform-tool help apply "
			puts "$> foreman-platform-tool delete".colorize(:yellow)
			puts "  To know more about 'delete' command, use help command with 'delete'. Ex: $> foreman-platform-tool help delete "
			puts ""
			puts ""
			puts "Logger optional parameters"
			puts "  --debug: This will display the debug information"
			puts "  --trace: This will display the error trace in detailed"
			puts ""
			puts "NOTE: All commands will accept foreman settings like --foreman_url=http://your-foreman.com --foreman_username=admin --foreman_password=changeme"

			puts "For detail doc refer below URL"
			puts "https://github.com/ingenico-group/foreman-platform-tool-cli"
		end

		def read_help
			puts "Command: read"
			puts "Description: Get blueprint(specification) yaml from existing foreman environment."
			puts "\n"
			puts "Mandatory Arguments"
			puts "  --environment: First argument is the name of the environment"
			puts "Optional Arguments"
			puts "  --foreman_url: This will override the foreman url from configuration"
			puts "  --foreman_username: This will override the foreman username from configuration"
			puts "  --foreman_password: This will override the foreman password from configuration"
			puts "Examples"
			puts "  $> foreman-platform-tool read --environment=a014rds04".colorize(:yellow)
			puts "Above command will return YAML content if environment is exists in foreman" 
		end

		def read(args)			
			Foreman::Platform::Tool::Platform.read(args)
		end

		def apply_help
			puts "Command: apply"
			puts "Description: Deploy/update platform."
			puts "\n"
			puts "Mandatory Arguments"
			puts "  --blueprint: Blueprint YAML file path"
			puts "  --environment: Platform name"
			puts "  --organization: Name of the organization that platform to apply"
			puts "Optional Arguments"
			puts "  --foreman_url: This will override the foreman url from configuration"
			puts "  --foreman_username: This will override the foreman username from configuration"
			puts "  --foreman_password: This will override the foreman password from configuration"
			puts "  --noop: This is to display the list of changes that will happen when update the existing platform"
			puts "Examples"
			puts "  $> foreman-platform-tool apply --blueprint=/path/to/blueprint.yml --environment=test --organization=ivs --compute_resource=peru".colorize(:yellow)
			puts "Above command will deploy/update platform" 
		end

		def apply(args)
			Foreman::Platform::Tool::Platform.deploy(args)
		end

		def delete_help
			puts "Command: delete"
			puts "Description: delete all hosts created under given environment and delete environment with given name"
			puts "\n"
			puts "Mandatory Arguments"
			puts "  --environment: Platform name"
			puts "Optional Arguments"
			puts "  --foreman_url: This will override the foreman url from configuration"
			puts "  --foreman_username: This will override the foreman username from configuration"
			puts "  --foreman_password: This will override the foreman password from configuration"
			puts "Examples"
			puts "  $> foreman-platform-tool delete --environment=test ".colorize(:yellow)
			puts "Above command will delete all hosts created under environment 'test' and environment with name 'test'" 
		end

		def delete(args)
			Foreman::Platform::Tool::Platform.delete(args)
		end



  end
end
