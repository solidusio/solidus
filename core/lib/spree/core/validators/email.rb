require 'validates_email_format_of'

class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if email_validation_messages(value).blank?
    record.errors.add(attribute, :invalid, { value: value }.merge!(options))
  end

  private

  def email_validation_messages(value)
    ValidatesEmailFormatOf.validate_email_format(value)
  end
end
