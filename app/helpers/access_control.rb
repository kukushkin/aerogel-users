# Returns +true+ is user allowed to access +path+ with operation +access+.
#
def can? path, access = Access::READ
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


# Returns constructed link if READ access to +url+ is allowed, returns empty string otherwise.
#
def link_to_if_can( url, text = url, opts = {} )
  link_to( url, text, opts ) if can?( url )
end


def on_access_denied( &block )
  @on_access_denied_callback = block if block_given?
  @on_access_denied_callback
end