class Api::V1::BaseController < ApplicationController
  skip_forgery_protection
  before_action :authenticate_internal_ai!

  private

  def authenticate_internal_ai!
    token = internal_ai_token
    configured_token = ENV["INTERNAL_AI_API_TOKEN"].to_s

    if configured_token.blank?
      render json: { error: "Internal AI API token is not configured." }, status: :service_unavailable
      return
    end

    unless token.present? && ActiveSupport::SecurityUtils.secure_compare(token, configured_token)
      render json: { error: "Unauthorized." }, status: :unauthorized
    end
  end

  def internal_ai_token
    bearer_token.presence || request.headers["X-Internal-AI-Token"].to_s
  end

  def bearer_token
    authorization = request.headers["Authorization"].to_s
    scheme, token = authorization.split(" ", 2)
    return if scheme.to_s.downcase != "bearer"

    token.to_s
  end
end
