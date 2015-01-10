class Operation
  attr_accessor :name, :attributes

  BOD_OPERATIONS = %i( create_bod_meta update_bod_meta create_bod_msg)
  PEOPLE_OPERATIONS = %i( create_person update_person )
  EMPLOYMENT_OPERATIONS = %i( create_employment update_employment )
  PAYPERIOD_OPERATIONS = %i( validate_pay_group )

  WEBMETHODS_OPERATIONS = BOD_OPERATIONS | PEOPLE_OPERATIONS |
  EMPLOYMENT_OPERATIONS | PAYPERIOD_OPERATIONS | %i( read_retro_date )

  PARAMS_CREATE_BOD_META = %i(bod_id gcc lcc payroll_exchange_id parent_bod_id
    event acknowledge_date_time source_bod_id event_time_stamp system batch_position
    valid_from payserv_id original_file_name)

  PARAMS_UPDATE_BOD_META = %i(bod_id gcc state payroll_exchange_id payserv_id confirm_bod_id
    acknowledge_bod_id parent_bod_id long_orchestration_id event_time_stamp system
    sequence_number ticket_id pay_group_id)

  PARAMS_CREATE_BOD_MSG = %i(bod_id gcc lcc bod_file event_time_stamp source_file_name)

  PARAMS_UPDATE_EMPLOYMENT = %i(payroll_exchange_id lcc payserv_id pay_group_id start_date end_date state
    alternative_ids)

  PARAMS_CREATE_EMPLOYMENT = %i(payroll_exchange_id payserv_id employee_id pay_group_id start_date)

  PARAMS_CREATE_PERSON = %i(gcc payroll_exchange_id person_id family_name given_name mobile_phone land_phone
    preferred_name email language status forgerock_id database_authenticatable role_list lcc_list password)

  PARAMS_UPDATE_PERSON = %i(payroll_exchange_id family_name given_name mobile_phone land_phone preferred_name
    email language status forgerock_id database_authenticatable role_list role_list lcc_list password)

  def initialize(name, date, attributes={})
    @name = name
    @date = date
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
