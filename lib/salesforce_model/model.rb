module SalesforceModel::Model
  extend ActiveSupport::Concern


  included do
    class_attribute :model_to_salesforce_names, default: {}
    class_attribute :salesforce_to_model_names, default: {}
    class_attribute :salesforce_types, default: {}
  end


  class_methods do
    def field(name, salesforce_name:nil, type:nil)
      raise ArgumentError 'name required' if name.nil?

      # Add read/write methods for the field
      attr_accessor name

      # Assume a sane Salesforce name if none is passed
      salesforce_name = name.to_s.classify if salesforce_name.nil?

      # Update our internal mappings
      model_to_salesforce_names[name] = salesforce_name
      salesforce_to_model_names[salesforce_name] = name
      salesforce_types[name] = type if type.present?
    end

    def fields
      model_to_salesforce_names.keys
    end
  end


  def fields
    self.class.fields
  end

  def to_salesforce
    fields.reduce({}) do |memo, field_name|
      sfdc_api_name = self.class.model_to_salesforce_names[field_name]
      memo[sfdc_api_name] = send(field_name.to_sym)
      memo
    end
  end
end
