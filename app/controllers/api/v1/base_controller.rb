class Api::V1::BaseController < ApplicationController

    include Pundit

    rescue_from Pundit::NotAuthorizedError, with: :deny_access

    def deny_access
        api_error(status: 403)
    end

    # disable the CSRF token
    protect_from_forgery with: :null_session

    # disable cookies (no set-cookies header in response)
    before_action :destroy_session


    def destroy_session
        request.session_options[:skip] = true
    end

    attr_accessor :current_user

    def api_error(opts = {})
        render nothing: true, status: opts[:status]
    end

    def unauthenticated!
        api_error(status: 401)
    end

    # 根据token识别用户
    def authenticate_user!
        token, options = ActionController::HttpAuthentication::Token.token_and_options(request)

        user_email = options.blank?? nil : options[:email]
        user = user_email && User.find_by(email: user_email)

        if user && ActiveSupport::SecurityUtils.secure_compare(user.authentication_token, token)
            self.current_user = user
        else
            return unauthenticated!
        end
    end

    def paginate(resource)
        resource = resource.page(params[:page] || 1)
        if params[:per_page]
            resource = resource.per(params[:per_page])
        end

        return resource
    end

end
