class SecuritySchemeAssignment < ApplicationRecord
  belongs_to :route
  belongs_to :security_scheme
end
