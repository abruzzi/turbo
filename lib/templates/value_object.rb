require 'ostruct'

class TestCase
  attr_accessor :name, :url, :headers, :type, :data_path, :debug, :success

  def initialize(args)
    obj = OpenStruct.new(args)
    @name = obj.name
    @url = obj.url
    @headers = obj.headers || {}
    @type = obj.type || "GET"
    @data_path = obj.data_path
    @success = obj.success
    @debug = obj.debug
  end

  def get_binding
    binding
  end
end

class SuccessDefinition
	attr_accessor :part, :type, :content

	def initialize(args)
		obj = OpenStruct.new(args)
		@part = obj.part
    @type = obj.type
    @content = obj.content
	end

	def get_binding
    	binding
  	end
end

class ExecutableTest
	attr_accessor :name, :command, :success

	def initialize(args)
		obj = OpenStruct.new(args)
		@name = obj.name
		@command = obj.command
		@success = obj.success
	end

	def get_binding
    	binding
  	end
end
