# Returns +true+ is user allowed to access +path+ with operation +access+.
#
def can? path, access
  applied_rules = Access.rules_for_path path

  # no rules for the path mean the access is not restricted
  return true if applied_rules.blank?

  # there are rules for the path, but the user is not authenticated
  return false unless current_user?

  # check if any rule grants access to path/access/user roles.
  applied_rules.each do |access_rule|
    return true if access_rule.grants?( path, access, current_user.roles )
  end

  # no luck
  return false
end

# Before serving any route check for access permissions.
#
before do
  access = %w(GET HEAD).include?( request.request_method.upcase.to_s ) ? Access::READ : Access::WRITE
  unless can? request.path_info, access
    flash[:error] = "Access denied: #{request.path_info} (#{access})"
    redirect "/"
  end
end

