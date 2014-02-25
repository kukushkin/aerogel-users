class Access

  include Model

  R = :R
  W = :W
  RW = :RW
  ACCESS_TYPES = [R, W, RW]

  field :path, type: String
  field :access, type: Symbol
  field :role, type: Symbol
  field :path_matcher, type: Regexp

  validates_presence_of :path, :access, :role
  validates :access, inclusion: { in: ACCESS_TYPES }

  def path=( value )
    self.path_matcher = self.class.compile_matcher value
    puts "path=#{value}, path_matcher=#{path_matcher}"
    super( value )
  end

  def match?( path )
    path_matcher =~ path
  end

  def self.rules_for_path( path )
    self.all.select{|r| r.match? path }
  end

private

  def self.compile_matcher( path )
    re = path.gsub(/\*{1,2}/) do |match|
      match == "**" ? ".*" : "[^\/]*"
    end
    Regexp.new "^#{re}$"
  end

end # class Access