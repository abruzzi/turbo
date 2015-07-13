#!/usr/bin/env ruby

require 'json'
require 'term/ansicolor'
require 'hashugar'
require 'rexml/document'
include REXML

require 'hash_recursive'
require 'commander'

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
      @run_success = 0
      @run_failed = 0

      execute_before_script
      scenarios.each do |scenario|
          run_scenario("#{@workflow_path}/scenarios/#{scenario}")
      end
      execute_after_script
  end

  private
  def execute_before_script
      system "#{@pre_command}"
  end

  def execute_after_script
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

	def load_common
		JSON.parse(File.read(@conf['conf_path'] + '/' + @conf['common_conf']))
	end

	def load_scenario(scenario)
		JSON.parse(File.read(scenario))
	end

  def bootstrap(scenario)
    config = load_common.rmerge(load_scenario(scenario)).to_hashugar

    def config.get_binding
      binding
    end

    config  
  end

  def run_scenario(scenario)
    generate_command(@workflow_path, bootstrap(scenario))
  end

end
