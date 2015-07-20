require "foreman/platform/tool/models/platform"
require "yaml"
module Foreman
  module Platform
    module Tool
      class Platform
        def self.read(args={})
            begin
                # raise "Invalid blueprint path #{args["blueprint"]}" if args["blueprint"].nil? or !File.exist?(args["blueprint"])
                raise "Environment name is required" if args["environment"].to_s.empty?
                platform = Foreman::Platform::Tool::Models::Platform.new(args)
                platform.read
            rescue Exception => e
                $logger.error e.message
                $logger.trace e.backtrace
                exit(1)
            end
        end


        def self.symbolize_keys_deep!(blueprint)
            blueprint.keys.each do |k|
                ks = k.respond_to?(:to_s) ? k.to_s : k
                blueprint[ks] = blueprint.delete k # Preserve order even when k == ks
                self.symbolize_keys_deep!(blueprint[ks]) if blueprint[ks].kind_of? Hash
            end
            blueprint
        end


        def self.deploy(params={})
            platform = nil
            begin
                candidates = [ "/etc/foreman-platform-tool/platform.yml", "#{File.expand_path('~')}/.foreman-platform-tool/platform.yml", "#{File.expand_path('.')}/platform.yml"]
                platform_settings = {}
                for candidate in candidates
                    platform_settings = YAML.load(File.read("#{candidate}")) if File.exist?(candidate)
                end
                args = (self.symbolize_keys_deep!(platform_settings)["platform"] || {}).merge(params)
                raise "Invalid blueprint path #{args["blueprint"]}" if args["blueprint"].nil? or !File.exist?(args["blueprint"])
                raise "Environment name is required" if args["environment"].to_s.empty?
                raise "Organization name is required" if args["organization"].to_s.empty?
                raise "Root password is required" if args["password"].to_s.empty?
                $logger.debug "Parsing blueprint yaml file"                        
                platform = Foreman::Platform::Tool::Models::Platform.new(args)
                platform.initialize_resources(self.symbolize_keys_deep!(YAML.load(File.read(args["blueprint"])).merge(args)))
                if !args["noop"].nil? and platform.is_environment_exist_in_foreman?
                    platform.display_changes
                else
                    platform.install
                end                        
            rescue Exception => e
                # platform.revert if platform.kind_of? Foreman::Platform::Tool::Models::Platform
                $logger.error e.message
                $logger.trace e.backtrace
                exit(1)
            end
        end

        def self.delete(args={})
            begin
                # raise "Invalid blueprint path #{args["blueprint"]}" if args["blueprint"].nil? or !File.exist?(args["blueprint"])
                raise "Environment name is required" if args["environment"].to_s.empty?
                platform = Foreman::Platform::Tool::Models::Platform.new(args)
                platform.delete
            rescue Exception => e
                $logger.error e.message
                $logger.trace e.backtrace
                exit(1)
            end
        end

      end
    end
  end
end