require 'json'
require './hash_recursive_merge.rb'

class Turbo
	def initialize(conf="turbo.conf")
		@conf = JSON.parse(File.read(conf))
		p @conf
	end

	def run(scenario=nil)
		if scenario
			run_scenario(scenario)
		else
			Dir.glob(@conf['scenarios_path']) do |json_file|
				run_scenario(json_file)
			end
		end
	end

	private

	def generate_header(obj)
		headers = []
		obj.each_pair do |k, v|
			headers << "-H \"#{k}: #{v}\""
		end
		headers.join(' ')
	end

	def load_common
		JSON.parse(File.read(@conf['common_conf']))
	end

	def load_scenario(scenario)
		JSON.parse(File.read(scenario))
	end

	def run_scenario(scenario)
		common = load_common
		config = common.rmerge(load_scenario(scenario))

		if config['disabled']
			puts "skipping scenario"
			return
		end

		# generate all headers
		headers = generate_header(config['headers'])
		
		# generate HTTP method
		method = "-X #{config['method']}"

		# run each case here
		config['cases'].each do |caze|
			path = config['baseurl'] + caze['path']
			data = config['method'] == "POST" ? "-d @#{caze['data']}" : ""
			debug = @conf['debug'] == 'true' || config['debug'] == 'true' ? "-D - -o debug.log" : ""
			command = "curl -is #{headers} #{method} #{data} #{path} #{debug}"
			puts "#{config['method']} #{path}"
			puts command
			system "#{command} | ack \"#{caze['success']}\"; ./bin/coloroutput $?"
		end
	end
end

# Turbo.new.run('scenarios/local-user-post.json')
# Turbo.new.run('scenarios/local-user-get.json')
Turbo.new.run