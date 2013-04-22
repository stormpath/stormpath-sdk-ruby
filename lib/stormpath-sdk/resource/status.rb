module Stormpath::Status

  ENABLED = 'ENABLED'
  DISABLED = 'DISABLED'

  def status_hash
    {ENABLED => ENABLED, DISABLED => DISABLED}
  end

end
