require 'erb'
require 'json'
require 'hashugar'
require 'jsonpath'

require 'term/ansicolor'

require 'rexml/document'
include REXML

require './value_object'


class String
  include Term::ANSIColor
end

def verify(caze)
	result = `#{caze.command}`

	case caze.success.type
	when 'xpath'
		xmldoc = Document.new(result)
		nodes = XPath.match(xmldoc, "#{caze.success.content}")

		if nodes != nil
			puts "Case [#{caze.name}] passed".green
		else
			puts "Case [#{caze.name}] failed\nExpected: #{caze.success.content}\nGot: #{result}".red
		end
	when 'regexp'
		x = result.match(/#{caze.success.content}/)

		if x != nil
			puts "Case [#{caze.name}] passed".green
		else
			puts "Case [#{caze.name}] failed\nExpected: #{caze.success.content}\nGot: #{result}".red
		end		
	when 'jsonpath'
		nodes = JsonPath.on(result, "#{caze.success.content}")

		if nodes.size != 0
			puts "Case [#{caze.name}] passed".green
		else
			puts "Case [#{caze.name}] failed\nExpected: #{nodes}\nGot: #{result}".red
		end
	end
end


def generate_command(config)
	template = File.read(File.join(File.dirname(File.expand_path(__FILE__)), 'command.erb'))
	renderer = ERB.new(template)

	config.cases.each do |caze|
		test_case = TestCase.new({
			:name => caze.name,
			:url => "#{config.baseurl}/#{caze.path}",
			:headers => caze.headers,
			:type => caze.type,
			:data_path => caze.data,
			:success => SuccessDefinition.new(caze.success),
			:debug => caze.debug
		})

		command = renderer.result(test_case.get_binding).gsub("\n", " ").strip

		test = ExecutableTest.new({
			:name => caze.name,
			:command => command, 
			:success => SuccessDefinition.new(caze.success)
		})

		verify(test)
	end
end

def load_scenario(scenario)
	scenario = JSON.parse(File.read(scenario)).to_hashugar

	def scenario.get_binding
		binding
	end

	scenario
end

generate_command(load_scenario('resource-get.json'))