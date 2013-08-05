require 'json'

require './hash_recursive_merge.rb'

def generate_header(obj)
	headers = []
	obj.each_pair do |k, v|
		headers << "-H \"#{k}: #{v}\""
	end
	headers.join(' ')
end

def load_common
	JSON.parse(File.read('common.conf'))
end

def load_scenario(scenario)
	JSON.parse(File.read(scenario))
end

def run_scenario(scenario)
	common = load_common
	config = common.rmerge(load_scenario(scenario))

	# generate all headers
	headers = generate_header(config['headers'])
	
	# generate HTTP method
	method = "-X #{config['method']}"

	# run each case here
	config['cases'].each do |caze|
		path = config['baseurl'] + caze['path']
		data = config['method'] == "POST" ? "-d @#{caze['data']}" : ""
		command = "curl -is #{headers} #{method} #{data} #{path}"
		puts "#{config['method']} #{path}"
		system "#{command} | ack \"#{caze['success']}\"; $? == 0 ? echo 'success' : 'failed'"
	end
end

def main
	run_scenario('search.json')
end

main