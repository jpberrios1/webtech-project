# Parent of every controller in the public JSON API (version 1).
#
# It inherits from ActionController::API instead of ApplicationController on purpose:
# - no sessions, cookies, CSRF or allow_browser checks, which a JSON client doesn't need
# - the sign-in requirement and Pundit checks that ApplicationController will get in
#   Assignment 4 don't apply here: this API is public and only exposes published data
module Api
  module V1
    class BaseController < ActionController::API
      rescue_from ActiveRecord::RecordNotFound do
        render_errors("There is no #{controller_name.singularize} with id #{params[:id]}", :not_found)
      end

      # Raised by the parsing helpers below when a query parameter has an invalid value
      rescue_from ActionController::BadRequest do |error|
        render_errors(error.message, :bad_request)
      end

      # Any /api/v1/... path that doesn't match a route (see config/routes.rb)
      def route_not_found
        render_errors("There is no route for #{request.method} #{request.path}", :not_found)
      end

      private

      # Every error has the same shape: { "errors": ["..."] }
      def render_errors(messages, status)
        render json: { errors: Array(messages) }, status: status
      end

      # --- Query parameter parsing ------------------------------------------------
      # Each helper turns a string from the URL into the right type, or raises
      # BadRequest so the client gets a 400 that says which parameter is wrong.

      def integer_param(name, value = params[name], min: 1)
        number = Integer(value.to_s, 10)
        raise ArgumentError if number < min

        number
      rescue ArgumentError
        raise ActionController::BadRequest, "#{name} must be an integer greater than or equal to #{min}"
      end

      def decimal_param(name)
        number = BigDecimal(params[name].to_s)
        raise ArgumentError if !number.finite? || number.negative?

        number
      rescue ArgumentError
        raise ActionController::BadRequest, "#{name} must be a number greater than or equal to 0"
      end

      def date_param(name)
        Date.iso8601(params[name].to_s)
      rescue Date::Error
        raise ActionController::BadRequest, "#{name} must be a date in YYYY-MM-DD format"
      end

      def boolean_param(name)
        case params[name].to_s
        when "true", "1" then true
        when "false", "0" then false
        else raise ActionController::BadRequest, "#{name} must be true or false"
        end
      end
    end
  end
end
