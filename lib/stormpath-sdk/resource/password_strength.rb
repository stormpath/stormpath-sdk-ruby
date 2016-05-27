module Stormpath
  module Resource
    class PasswordStrength < Stormpath::Resource::Instance
      prop_accessor(
        :min_length,
        :max_length,
        :min_lower_case,
        :min_upper_case,
        :min_numeric,
        :min_symbol,
        :min_diacritic,
        :prevent_reuse
      )
    end
  end
end
