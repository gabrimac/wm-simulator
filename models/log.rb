require 'json'

class Log
  attr_accessor :operations

  def initialize(log)
    @log = log
    @operations = []
  end

  def convert_to_operations
    read
    @operations
  end

  private

  def tags(line)
    (/(\[.*\])/.match(line)[0]).split(' ').map {|tag| tag.gsub(/[\[\])]/, "")}
  end

  def read
    @log.content.split(/\n/).each do |line|
      operation = nil
      tags = tags(line)
      next if tags[1] == "PEX->WM"
      Operation::WEBMETHODS_OPERATIONS.each do |operation_sym|
        if line.include? operation_sym.to_s
          operation = Operation.new(operation_sym, tags[0])
          @operations << operation
        end
      end
      operation = @operations.last if operation.nil?
      message = JSON.parse(/(\{.*\})/.match(line)[0])
      convert_to_params(message, operation)
    end
  end

  def convert_to_params(message, operation, attribute=nil)
    if message.is_a? Hash
      message.each { |key, value| convert_to_params(value, operation, key) }
    else
      operation.add_attribute(attribute, message) if attribute && attribute = convert_to_valid(attribute, operation)
    end
  end

  def convert_to_valid(attribute, operation)
    return attribute if operation_include_attribute(attribute, operation)
    irregular_attribute(attribute, operation)
  end

  def irregular_attribute(attribute, operation)
    case attribute
    when "payroll_service_id"
      return "payserv_id" if operation_include_attribute("payserv_id", operation)
    end
  end

  def operation_include_attribute(attribute, operation)
    Operation.const_get("PARAMS_#{operation.name.upcase}").include? attribute.to_sym
  end

end
