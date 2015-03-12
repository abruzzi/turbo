#!/usr/bin/env ruby

require 'json'
require 'term/ansicolor'
require 'rexml/document'
include REXML


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
      @debug_file = 'debug.log'

      scenarios = wf['scenarios']
      @total_scenarios_num = 0
      @scenarios_num = 1
      @run_success = 0
      @run_failed = 0
      before
      scenarios.each do |scenario|
        calculate_scenario_num("#{@workflow_path}/scenarios/#{scenario}")
      end
      puts "1..#{@total_scenarios_num}"
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
  def calculate_scenario_num(scenario)
    common = load_common
    config = common.rmerge(load_scenario(scenario))
    config['cases'].each do |caze|
      @total_scenarios_num += 1
    end

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

    @scenario_name = config['scenario_name']

		# run each case here
		config['cases'].each do |caze|
			path = config['baseurl'] + caze['path']
			data = config['method'] == "POST" || config['method'] == "PUT" ? "-d @#{@workflow_path}/#{caze['data']}" : ""

      debug = @conf['debug'] == 'true' || config['debug'] == 'true' ? "-D - -o debug.log" : ""

      real_command = "curl -is #{headers} #{method} #{data} #{path} #{debug}"

      if(File.exist?(@debug_file))
        system("rm #{@debug_file}")
      end

      if (caze['success'].is_a? Hash)
        if (caze['success'].has_key? 'regexp')
          ret = regexp(real_command, caze['success']['regexp'])
        elsif ((caze['success'].has_key? 'xpath'))
          ret = xpath(real_command, caze['success']['xpath'])
        end
      else
        ret = regular(real_command, caze['success'])
      end

      outputs(ret, caze)
      @scenarios_num += 1
  		end
  end

  def xpath command, pattern
    `#{command}`
    xmldoc = Document.new(File.new(@debug_file))
    matched_times = 0
    father_node_numbers =0

    father_node = pattern.match(/\/\/[a-z A-Z]+/).to_s
    child_node = pattern.match(/\[\@[a-z A-Z]+\=\'[a-z A-Z]+\'\]/).to_s
    child_node_key = child_node.match(/\[\@[a-z A-Z]+/).to_s.split('@')[1]
    child_node_value =child_node.match(/\=\'[a-z A-Z]+/).to_s.split('\'')[1]

    xmldoc.elements.each(father_node) {|e|father_node_numbers +=1}
    xmldoc.elements.each(father_node+"/"+child_node_key) {|result| matched_times +=1 if result.text ==child_node_value }

    matched_times >= father_node_numbers
  end

  def regexp command, pattern
    result = `#{command}`
    if result != ""
      http_code = result.split(/\r?\n/).first.split(' ')[1]
      pattern.split('|').include? http_code
    end
  end

  def regular command, pattern
    result = `#{command}`
    if result != ""
      http_code = result.split(/\r?\n/).first.split(' ')[1]
      pattern.include? http_code
    end
  end

  def outputs(ret, caze)
    if(File.exist?(@debug_file))
      arr = IO.readlines(@debug_file)
    end

    if ret
      @run_success += 1
      puts "ok - #{@scenario_name} #{caze['case_name']}".green
    else
      @run_failed += 1
      if arr
        puts "not ok - #{@scenario_name} #{caze['case_name']}".red
        puts "#\tExpected: #{caze['success']}".red
        print "#\tActual: #{arr[0]}".red
      else
        puts "not ok - #{@scenario_name} #{caze['case_name']}".red
        puts "#\tExpected: #{caze['success']}".red
        puts "#\tActual: Connection refused".red
      end
    end
  end
end
