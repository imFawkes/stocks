class Products::Sell
  Result = Struct.new(:success?, :error_message, :error_code)

  def call(params)
    @quantity = params[:quantity]
    @product_id = params[:id]
    return Result.new(false, 'not enough products', 422) if stocklists.sum(&:quantity) < quantity

    quantity_requested = quantity

    ActiveRecord::Base.transaction do
      stocklists.each do |stocklist|
        warehouse = stocklist.warehouse

        stocklist.lock!
        warehouse.lock!
        if stocklist.quantity >= quantity_requested
          warehouse.balance += product.price * quantity_requested
          warehouse.save!
          stocklist.quantity -= quantity_requested
          stocklist.save!
          break
        end

        warehouse.balance += product.price * stocklist.quantity
        warehouse.save!
        quantity_requested -= stocklist.quantity
        stocklist.update!(quantity: 0)
      end
    end

    Result.new(true)
  end

  private

  attr_reader :quantity, :product_id

  def product
    @product ||= Product.find(product_id)
  end

  def stocklists
    @stocklists ||= product.stocklists.includes(:warehouse)
  end
end
