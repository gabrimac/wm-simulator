class AtlasConnector

  ATLAS_WSDLS = %w( /api/bods/wsdl /api/people/wsdl /api/employments/wsdl
  /api/pay_groups/wsdl )

  def initialize(operation)
    @operation = operation
    @client = Savon.client(wsdl: choose_path(operation), convert_request_keys_to: :camelcase)
  end

  def perform_call(message)
    response = @client.call(@operation, message: message)
  end

  def choose_path(operation)
    wsdl = "http://localhost:3000"

    return "#{wsdl}#{ATLAS_WSDLS.first}" if Operation::BOD_OPERATIONS.include? operation
    return "#{wsdl}#{ATLAS_WSDLS.at(1)}" if Operation::PEOPLE_OPERATIONS.include? operation
    return "#{wsdl}#{ATLAS_WSDLS.at(2)}" if Operation::EMPLOYMENT_OPERATIONS.include? operation
    return "#{wsdl}#{ATLAS_WSDLS.at(3)}" if Operation::PAYPERIOD_OPERATIONS.include? operation
  end

end
