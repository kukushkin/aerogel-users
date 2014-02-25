# Returns +true+ is user allowed to access +path+ with operation +access+.
#
def can? path, access
  applied_rules = Access.rules_for_path path
  return true if applied_rules.blank?
  return false unless current_user?
  applied_rules.select{|r| current_user.roles.include? r.role }.each do |access_rule|
    return true if access_rule.access == :RW || access_rule.access == access
  end
  return false
end

# Before serving any route check for access permissions.
#
before do
  methods_read = %w(get head)
  access = %w(GET HEAD).include?( request.request_method.upcase.to_s ) ? :R : :W
  unless can? request.path_info, access
    flash[:error] = "Access denied: #{request.path_info}"
    redirect "/"
  end
end

