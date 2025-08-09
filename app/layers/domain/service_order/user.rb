module Domain
  module ServiceOrder
    class User < Infra::Models::ApplicationRecord
      has_secure_password
    end
  end
end
