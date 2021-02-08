class API < Grape::API
  format :json
  default_format :json

  rescue_from Grape::Exceptions::ValidationErrors do |e|
    Rack::Response.new([{ error: e.full_messages }.to_json], 400, 'ContentType' => 'text/error')
  end

  rescue_from ActiveRecord::RecordInvalid do |e|
    Rack::Response.new([{ error: e.message }.to_json], 422, 'ContentType' => 'text/error')
  end

  rescue_from ActiveRecord::RecordNotFound do |e|
    Rack::Response.new([{ error: e.message }.to_json], 404, 'ContentType' => 'text/error')
  end

  rescue_from :all do |e|
    Rack::Response.new([{ error: e.message }.to_json], 500, 'ContentType' => 'text/error')
  end

  # Endpoints
  mount ProductsController
end
