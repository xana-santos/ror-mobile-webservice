class V1::UsersController < ApiController

  def authenticate

    user = ::User.fetch_by_email(params["email"])

    if user && user.authenticate(params[:password])
      render json: {id: user.api_token, status: "authenticated", sign_up_time: user.created_at.to_i}, status: 200 and return
    else
      show_errors("Invalid email/password") or return
    end

  end

end
