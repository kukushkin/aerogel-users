class Access

  include Model

  READ = :R
  WRITE = :RW
  ACCESS_TYPES = [READ, WRITE]

  field :path, type: String
  field :access, type: Symbol
  field :role, type: Symbol
  field :path_matcher, type: Regexp

  validates_presence_of :path, :access, :role
  validates :access, inclusion: { in: ACCESS_TYPES }

  validate do |record|
    # validate roles
    if record.role_changed?
      unless Role.slugs.include? record.role
        record.errors.add :role, 'is invalid'
      end
    end
  end

  # Sets path pattern for the rule and compiles it to path matcher Regexp.
  #
  def path=( value )
    self.path_matcher = self.class.compile_matcher value
    super( value )
  end

  # Returns true if the rule matches path.
  #
  def match?( path )
    path_matcher =~ path
  end

  # Returns true if the rule permits requested access.
  # +path+ should match this rule's path
  # +access+ should be granted by this rule
  # +roles+ should include rule's role
  #
  def grants?( path, access, roles )
    roles = [*roles]
    self.match?( path ) && ( self.access == WRITE || self.access == access ) && roles.include?( role )
  end

  # Returns list of rules that restrict access to the given +path+.
  #
  def self.rules_for_path( path )
    self.all.select{|r| r.match? path }
  end


private

  # Returns Regexp matcher for given +path+ pattern.
  #
  def self.compile_matcher( path )
    re = path.gsub(/\*{1,2}/) do |match|
      match == "**" ? ".*" : "[^\/]*"
    end
    Regexp.new "^#{re}$"
  end

end # class Access