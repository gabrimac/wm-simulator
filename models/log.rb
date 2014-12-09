class Log
  attr_accessor :operations

  def initialize(log)
    @log = log
  end

  def convert_to_operations
    @operations = []
    @log.content.split(/\n/).each do |line|
      operation = nil
      Operation::WEBMETHODS_OPERATIONS.each do |operation_sym|
        if line.include? operation_sym.to_s
          operation = Operation.new(operation_sym)
          @operations << operation
        end
      end
      operation = @operations.last if operation.nil?
      next unless line.include? "raw"
      line = line.split(/\"raw\"=>/).second
      line.split(/,/).each do |param|
        attribute = nil
        value = nil
        param.split(/\"/).each do |elem|
          next if elem.include?("parsed") || elem.include?("created_at") || elem.include?("updated_at") || elem.include?("description") || elem.include?("system_id") || elem.include?("country_code") || elem.include?("original_create_at") || elem.include?("code")
          attribute = "bod_id" if attribute.nil? && /[a-zA-Z0-9_-]*/.match(elem).to_s != "" && elem.include?("internal_bod_id")
          value = elem if attribute.present? && /[a-zA-Z0-9_-]*/.match(elem).to_s != ""
          attribute = elem if attribute.nil? && /[a-zA-Z0-9_-]*/.match(elem).to_s != ""
        end
        operation.add_attribute(attribute, value) if value
      end
    end
    @operations
  end
end
