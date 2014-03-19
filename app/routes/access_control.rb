
# Before serving any route check for access permissions.
#
before do
  access = %w(GET HEAD).include?( request.request_method.upcase.to_s ) ? Access::READ : Access::WRITE
  unless can? request.path_info, access
    flash[:error] = t.aerogel.auth.actions.access_denied path: request.path_info, access: access

    # on_access_denied callback redefines flash[:error] and raises redirect exception
    on_access_denied.call( request.path_info, access ) if on_access_denied.present?

    redirect "/"
  end
end

