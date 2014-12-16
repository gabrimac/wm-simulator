class Operation
  attr_accessor :name, :attributes

  BOD_OPERATIONS = %i( create_bod_meta update_bod_meta create_bod_msg)
  PEOPLE_OPERATIONS = %i( create_person update_person )
  EMPLOYMENT_OPERATIONS = %i( create_employment update_employment )
  PAYPERIOD_OPERATIONS = %i( validate_pay_group )

  WEBMETHODS_OPERATIONS = BOD_OPERATIONS | PEOPLE_OPERATIONS |
  EMPLOYMENT_OPERATIONS | PAYPERIOD_OPERATIONS | %i( read_retro_date )

  def initialize(name, attributes={})
    @name = name
    @attributes = []
    attributes.each do |attribute, value|
      instance_variable_set("@#{attribute}", value)
      self.class.send(:attr_accessor, attribute)
      @attributes << attribute
    end
  end

  def add_attribute(attribute, value)
    unless @attributes.include? attribute
      value = Time.now if attribute == "event_time_stamp"
      instance_variable_set("@#{attribute}", value)
      self.class.send(:attr_accessor, attribute)
      @attributes << attribute
    end
  end

  def execute(response_name)
    params = Hash[ @attributes.collect { |attr| [attr, self.send(attr)] } ]
    content = AtlasConnector.new(@name).perform_call(params)
    response = Response.new(response_name, content)
    response.save
  end

end
