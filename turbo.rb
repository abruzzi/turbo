require 'json'
require './lib/hash_recursive_merge.rb'

class Turbo
    def before
        system "#{@pre_command}"
    end

    def after
        system "#{@post_command}"
    end

	def initialize(conf="config/turbo.conf")
		@conf = JSON.parse(File.read(conf))
        @conf['conf_path'] = File.dirname(File.absolute_path(conf))
		p @conf
	end

    def run_workflow(workflow=nil)
        dirname = File.dirname(File.absolute_path(workflow))
        workflow = JSON.parse(File.read(workflow))
        
        @workflow_path = dirname + '/'
        @pre_command = @workflow_path + workflow['before']
        @post_command = @workflow_path + workflow['after']

        scenarios = workflow['scenarios']
        
        before
        scenarios.each do |scenario|
            p dirname + '/' + scenario
            run_scenario(@workflow_path + scenario)
        end
        after
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
		JSON.parse(File.read(@conf['conf_path'] + '/' + @conf['common_conf']))
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
			data = config['method'] == "POST" || config['method'] == "PUT" ? "-d @#{@workflow_path}#{caze['data']}" : ""
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
# Turbo.new.run
# Turbo.new.run "scenarios/mycommercial-bookmark-create.json"
# Turbo.new("echo 'a'", "echo 'b'").run("scenarios/mycommercial-bookmark.json")

# Turbo.new.run("scenarios/login-flow.json")
# Turbo.new.run_workflow("scenarios/mycommercial/login-flow.json")
Turbo.new.run_workflow("scenarios/moco/moco-flow.json")

