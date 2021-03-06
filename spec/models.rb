EMAIL_SPLIT_PATTERN = /\A(?<email_local>[^@]+)@(?<email_domain>[^@]+)\Z/
EMAIL_JOIN_PROCESS  = Proc.new{|values| values.join('@') }

class Splittable < ActiveRecord::Base

  acts_as_splittable

  splittable :email,        split: ['@', 2], partials: [:email_local, :email_domain], on_join: EMAIL_JOIN_PROCESS
  splittable :postal_code,  pattern: /\A(?<postal_code1>[0-9]{3})(?<postal_code2>[0-9]{4})\Z/
  splittable :phone_number, partials: [:phone_number1, :phone_number2, :phone_number3], on_split: :split_phone_number, on_join: :join_phone_number

  protected

  def split_phone_number(value)
    return if value.nil?
    [value[0, 3], value[3, 4], value[7, 4]]
  end

  def join_phone_number(values)
    values.join
  end
end

class SplittableInherited < Splittable; end
class SplittableInheritedInherited < SplittableInherited; end

class SplittableWithValidation < ActiveRecord::Base
  self.table_name = 'splittables'

  acts_as_splittable

  splittable :email, pattern: EMAIL_SPLIT_PATTERN, on_join: EMAIL_JOIN_PROCESS

  validates :email_local,  format: { with: /\A[a-zA-Z0-9_.-]+\Z/ }
  validates :email_domain, format: { with: /\A(?:[a-zA-Z0-9-]+\.)+[a-zA-Z]{2,4}\Z/ }
end

class SplittableWithValidationForOriginalColumn < ActiveRecord::Base
  self.table_name = 'splittables'

  acts_as_splittable callbacks: false

  splittable :email, pattern: EMAIL_SPLIT_PATTERN, on_join: EMAIL_JOIN_PROCESS

  validates :email, format: { with: /\A[a-zA-Z0-9_.-]+@(?:[a-zA-Z0-9-]+\.)+[a-zA-Z]{2,4}\Z/ }
end