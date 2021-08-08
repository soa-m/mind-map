ActiveRecord::Base.establish_connection

class Card < ActiveRecord::Base
end

class User < ActiveRecord::Base
    has_secure_password
end