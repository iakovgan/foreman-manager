require "foreman_api"

class ForemanSettings

	attr_accessor :user_id, :url, :username, :password

	def initialize(args={})		
		args.each do |name, value|
			self.instance_eval { class << self; self end }.send(:attr_accessor, name)
			#ForemanSettings.class.module_eval { attr_accessor :name}
			send("#{name}=", value)
		end
		self.ask_foreman_url
		self.ask_username
		self.ask_password
	end

	def api_url
		#url.to_s+(!url.to_s.end_with?("/") ? "/" : "")+"api"+(!api_version.to_s.empty? ? "/"+api_version : "")
		url.to_s+"/api/v2"
	end

	def get_user_id
		@user_id ||= ForemanApi::User.new.get_id(@username)
	end

	def ask_foreman_url
		return @url.chomp("/") unless @url.to_s.empty? 
		print "[Foreman] URL: "
		self.url = STDIN.gets.strip().chomp("/")
		return !@url.to_s.empty? ? @url : ask_foreman_url		
	end

	def ask_username
		return @username unless @username.to_s.empty? 
		print "[Foreman] Username: ";
		self.username = STDIN.gets.strip;
		return !@username.to_s.empty? ? @username : ask_username		
	end

	def ask_password
		return @password unless @password.to_s.empty? 
		print "[Foreman] Password for %s: " % @username;
		self.password = STDIN.noecho(&:gets).chomp.strip;
		puts ""
		return !@password.to_s.empty? ? @password : ask_password		
	end

	def self.load(args)
		candidates = [ "/etc/foreman-platform-tool/foreman.yml", "#{File.expand_path('~')}/.foreman-platform-tool/foreman.yml", "#{File.expand_path('.')}/foreman.yml"]
		
		settings = {}
		for candidate in candidates
			begin
				settings = YAML.load(File.read("#{candidate}")) if File.exist?(candidate)
			rescue Exception => e

			end
		end
		settings["foreman"] = {} if  settings.empty?
		if !args["foreman_url"].nil? 
			settings["foreman"].merge!({"url" => args["foreman_url"]})
		end

		if !args["foreman_username"].nil? 
			settings["foreman"].merge!({"username" => args["foreman_username"]})
		end
		if  !args["foreman_password"].nil?
			settings["foreman"].merge!({"password" => args["foreman_password"]})
		end
		if settings.empty?
			raise "No config file found in #{candidates.join(', ')}" 
		else
			fsettings = ForemanSettings.new(settings["foreman"])
		end 
		
		return fsettings
	end

	

	
end
