#!/usr/bin/env ruby

require 'json'
require 'term/ansicolor'

# Author::      Simone Carletti <weppos@weppos.net>
# Copyright::   2007-2008 The Authors
# License::     MIT License
# Link::        http://www.simonecarletti.com/
# Source::      http://gist.github.com/gists/6391/
#
module HashRecursiveMerge
  def rmerge!(other_hash)
    merge!(other_hash) do |key, oldval, newval|
        oldval.class == self.class ? oldval.rmerge!(newval) : newval
    end
  end

  def rmerge(other_hash)
    r = {}
    merge(other_hash)  do |key, oldval, newval|
      r[key] = oldval.class == self.class ? oldval.rmerge(newval) : newval
    end
  end
end

class Hash
  include HashRecursiveMerge
end

class String
  include Term::ANSIColor
end

class Turbo

	def initialize(conf)
    f = File.join(File.dirname(File.expand_path(__FILE__)), conf ? conf : "config/turbo.conf")
		@conf = JSON.parse(File.read(f))
    @conf['conf_path'] = File.dirname(File.absolute_path(f))
	end

  def run_workflow(workflow=nil)
      wf = JSON.parse(File.read("workflows/#{workflow}/workflow.json"))

      @workflow_path = "workflows/#{workflow}"
      @pre_command = "#{@workflow_path}/#{wf['before']}"
      @post_command = "#{@workflow_path}/#{wf['after']}"

      scenarios = wf['scenarios']

      before
      scenarios.each do |scenario|
          run_scenario("#{@workflow_path}/scenarios/#{scenario}")
      end
      after

  end

  private
  def before
      system "#{@pre_command}"
  end

  def after
      system "#{@post_command}"
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
			puts "skipping scenario, #{scenario}".cyan
			return
		end

		# generate all headers
		headers = generate_header(config['headers'])

		# generate HTTP method
		method = "-X #{config['method']}"

		# run each case here
		config['cases'].each do |caze|
			path = config['baseurl'] + caze['path']
			data = config['method'] == "POST" || config['method'] == "PUT" ? "-d @#{@workflow_path}/#{caze['data']}" : ""

      debug = @conf['debug'] == 'true' || config['debug'] == 'true' ? "-D - -o debug.log" : ""

      real_command = "curl -is #{headers} #{method} #{data} #{path} #{debug}"
      puts real_command
      command = "#{real_command} | grep --color=auto -E \"#{caze['success']}\""

      ret = system(command)

      if ret
        puts "#{'Success'}: #{real_command}".green
      else
        puts "#{'Error'}: #{real_command}".red
      end
		end
	end
end
