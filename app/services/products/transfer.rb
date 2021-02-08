class Products::Transfer
  Result = Struct.new(:success?)

  def call(params)
    @product_id = params[:id]
    @warehouse_id = params[:warehouse_id]
    @new_warehouse_id = params[:new_warehouse_id]
    @quantity = params[:quantity] || stocklist.quantity

    ActiveRecord::Base.transaction do
      stocklist.lock!
      new_stocklist.lock!
      stocklist.quantity -= quantity
      stocklist.save!
      new_stocklist.quantity += quantity
      new_stocklist.save!
    end

    Result.new(true)
  end

  private

  attr_reader :quantity, :product_id, :warehouse_id, :new_warehouse_id

  def product
    @product ||= Product.find(product_id)
  end

  def warehouse
    @warehouse ||= Warehouse.find(warehouse_id)
  end

  def new_warehouse
    @new_warehouse ||= Warehouse.find(new_warehouse_id)
  end

  def stocklist
    @stocklist ||= Stocklist.find_by!(product: product, warehouse: warehouse)
  end

  def new_stocklist
    @new_stocklist ||= Stocklist.find_or_create_by!(product: product, warehouse: new_warehouse)
  end
end
