module Stormpath::Status

  ENABLED = 'ENABLED'
  DISABLED = 'DISABLED'

  def get_status_hash
    {ENABLED => ENABLED, DISABLED => DISABLED}
  end

end
