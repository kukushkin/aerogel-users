
# Before serving any route check for access permissions.
#
before do
  access = %w(GET HEAD).include?( request.request_method.upcase.to_s ) ? Access::READ : Access::WRITE
  unless can? request.path_info, access
    if on_access_denied.present?
      on_access_denied.call request.path_info, access
    else
      flash[:error] = "Access denied: #{request.path_info} (#{access})"
      redirect "/"
    end
  end
end

