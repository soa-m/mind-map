ActiveRecord::Base.establish_connection

class Card < ActiveRecord::Base
    belongs_to :list
end

class User < ActiveRecord::Base
    has_secure_password
    has_many :lists
end

class List < ActiveRecord::Base
    belongs_to :user
    has_many :cards
end