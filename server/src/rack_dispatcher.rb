require_relative 'starter'
require 'json'

class RackDispatcher

  def initialize(request = Rack::Request)
    @request = request
  end

  def call(env)
    request = @request.new(env)
    name, args = validated_name_args(request)
    starter = Starter.new
    result = starter.public_send(name, *args)
    body = { name => result }
    triple(body)
  rescue => error
    triple({ 'exception' => error.message })
  end

  private # = = = = = = = = = = = =

  def validated_name_args(request)
    name = request.path_info[1..-1] # lose leading /
    @json_args = json_parse(request.body.read)
    unless @json_args.is_a?(Hash)
      raise 'json:!Hash'
    end
    args = case name
      when /^languages_choices$/ then [display_name]
      when /^exercises_choices$/ then [exercise_name]
      else
        was_name = name
        name = 'unknown'
        args = [ was_name ]
    end
    [name, args]
  end

  def json_parse(request)
    JSON.parse(request)
  rescue
    raise 'json:invalid'
  end

  def triple(body)
    [ 200, { 'Content-Type' => 'application/json' }, [ body.to_json ] ]
  end

  # - - - - - - - - - - - - - - - -
  # method arguments
  # - - - - - - - - - - - - - - - -

  def display_name
    validated_display_name(arg('display_name'))
  end

  def exercise_name
    validated_exercise_name(arg('exercise_name'))
  end

  # - - - - - - - - - - - - - - - -
  # validations
  # - - - - - - - - - - - - - - - -

  def validated_display_name(arg)
    unless arg.is_a?(String) || arg.is_a?(NilClass)
      raise error('display_name', 'invalid')
    end
    arg
  end

  def validated_exercise_name(arg)
    unless arg.is_a?(String) || arg.is_a?(NilClass)
      raise error('exercise_name', 'invalid')
    end
    arg
  end

  # - - - - - - - - - - - - - - - -

  def arg(name)
    unless @json_args.key?(name)
      raise error(name, 'missing')
    end
    @json_args[name]
  end

  # - - - - - - - - - - - - - - - -

  def error(name, message)
    ArgumentError.new("#{name}:#{message}")
  end

end
