

# Before serving any route check for access permissions.
#
before do
  access = %w(GET HEAD).include?( request.request_method.upcase.to_s ) ? Access::READ : Access::WRITE
  unless can? request.path_info, access
    flash[:error] = "Access denied: #{request.path_info} (#{access})"
    redirect "/"
  end
end

