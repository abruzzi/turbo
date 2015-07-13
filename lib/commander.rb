require 'erb'
require 'json'
require 'hashugar'
require 'jsonpath'

require 'term/ansicolor'

require 'rexml/document'
include REXML

require 'value_object'


class String
  include Term::ANSIColor
end

def verfiy_xpath(caze, result)
	xmldoc = Document.new(result)
	nodes = XPath.match(xmldoc, "#{caze.success.content}")

	if nodes != nil
		puts "Case: ['#{caze.name}'] passed".green
	else
		puts "Case: ['#{caze.name}'] failed\nExpected: #{caze.success.content}\nGot: #{result}".red
	end
	puts "#{caze.type} #{caze.url}\n".cyan
end

def verify_regexp(caze, result)
	x = result.match(/#{caze.success.content}/)

	if x != nil
		puts "Case: ['#{caze.name}'] passed".green
	else
		puts "Case: ['#{caze.name}'] failed\nExpected: #{caze.success.content}\nGot: #{result}".red
	end
	puts "#{caze.type} #{caze.url}\n".cyan
end

def verify_jsonpath(caze, result)
	nodes = JsonPath.on(result, "#{caze.success.content}")

	if nodes.size != 0
		puts "Case: ['#{caze.name}'] passed".green
	else
		puts "Case: ['#{caze.name}'] failed\nExpected: #{nodes}\nGot: #{result}".red
	end
	puts "#{caze.type} #{caze.url}\n".cyan
end

def verify(caze)
	result = `#{caze.command}`

	case caze.success.type
	when 'xpath'
		verfiy_xpath(caze, result)
	when 'regexp'
		verify_regexp(caze, result)
	when 'jsonpath'
		verify_jsonpath(caze, result)
	end
end

def generate_command(workflow_path, config)
	template = File.read(File.join(File.dirname(File.expand_path(__FILE__)), 'templates/command.erb'))
	renderer = ERB.new(template)

	puts "Scenario: #{config.name}, test cases: #{config.cases.size}\n".cyan
	config.cases.each do |caze|
		test_case = TestCase.new({
			:name => caze.name,
			:url => "#{config.baseurl}/#{caze.path}",
			:headers => caze.headers,
			:type => caze.type,
			:data_path => "#{workflow_path}/#{caze.data ? caze.data.strip : ''}",
			:success => SuccessDefinition.new(caze.success),
			:debug => caze.debug
		})

		command = renderer.result(test_case.get_binding).gsub("\n", " ").strip

		test = ExecutableTest.new({
			:name => caze.name,
			:type => caze.type,
			:url => "#{config.baseurl}/#{caze.path}",
			:command => command, 
			:success => SuccessDefinition.new(caze.success)
		})

		verify(test)
	end
end
