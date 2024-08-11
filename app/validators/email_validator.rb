class EmailValidator < ActiveModel::EachValidator

  MAX_LENGTH = 50

  def validate_each(record, attribute, value)
    record.errors.add attribute, (options[:message] || 'is not a valid email') unless
      value && value.length < MAX_LENGTH && value =~ /\A[^@\s]+@[^@\s.]+\.+[^@\s]+\z/i
  end

end