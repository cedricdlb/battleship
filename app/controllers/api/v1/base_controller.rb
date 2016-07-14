class Api::V1::BaseController < ApplicationController
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  before_action :destroy_session

  def destroy_session
    request.session_options[:skip] = true
  end

  rescue_from ActiveRecord::RecordNotFound do |e|
   Rails.logger.warn "in Api::V1::BaseController, rescuing from ActiveRecord::RecordNotFound, e.message: #{e.message}"
    render json: { error: e.message }, status: :not_found
  end

  rescue_from ActiveRecord::RecordInvalid do |e|
   Rails.logger.warn "in Api::V1::BaseController, rescuing from ActiveRecord::RecordInvalid, e.message: #{e.message}"
    render json: { error: e.message }, status: :unprocessable_entity
  end

  rescue_from ActionController::ParameterMissing do |e|
   Rails.logger.warn "in Api::V1::BaseController, rescuing from ActionController::ParameterMissing, e.message: #{e.message}"
    render json: { error: e.message }, status: :unprocessable_entity
  end

end
