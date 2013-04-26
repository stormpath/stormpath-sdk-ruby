module Stormpath::Resource::Status

  ENABLED = 'ENABLED'
  DISABLED = 'DISABLED'

  def status_hash
    {ENABLED => ENABLED, DISABLED => DISABLED}
  end

  STATUS = "status"

  def status
    value = get_property STATUS

    if !value.nil?
      value = value.upcase
    end

    value
  end

  def status=(status)
    if status_hash.has_key? status
      set_property STATUS, status_hash[status]
    end
  end

end
