class ProductsController < Grape::API
  resource :products do
    desc 'POST /products/:id/transfer' do
      summary 'Move product from one warehouse to another'
    end

    params do
      requires :id, type: Integer, documentation: { in: 'path' }
      requires :warehouse_id, type: Integer, documentation: { in: 'body' }
      requires :new_warehouse_id, type: Integer, documentation: { in: 'body' }
      optional :quantity, type: Integer, documentation: { in: 'body' }
    end

    post '/:id/transfer' do
      Products::Transfer.new.call(params)
      status :no_content
    end

    desc 'POST /products/:id/sell' do
      summary 'Sell products'
    end

    params do
      requires :id, type: Integer, documentation: { in: 'path' }
      requires :quantity, type: Integer, documentation: { in: 'body' }
    end

    post '/:id/sell' do
      result = Products::Sell.new.call(params)
      error!(result.error_message, result.error_code) unless result.success?

      status :no_content
    end
  end
end
