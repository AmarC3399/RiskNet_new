class Report
  class AuthorityPolicy < Authority::Authorizer
    include Authority::Abilities

    def self.hi
      puts 'hi'
    end
  end
end