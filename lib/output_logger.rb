class OutputLogger

	attr_accessor :debug_mode, :info_mode, :trace

	def initialize(args={})
		args.each do |name, value|
			send("#{name}=", value)
		end
	end

	def error msg
		puts "[ ERROR ] #{msg}".colorize(:red)
	end

	def notice msg
		puts "[ SUCCESS ] #{msg}".colorize(:green)
	end

	def trace msg
		STDERR.puts msg if @trace
	end

	def debug(msg)
		puts "DEBUG: #{msg}"  if @debug_mode
	end

	def info(msg)
		puts "INFO: #{msg}" if @info_mode
	end

	def stdout(msg)
		STDOUT.puts msg
	end

end