require 'rails_helper'

describe ProductsController do
  describe 'POST /products/:id/transfer' do
    context 'when no product with such id' do
      let(:warehouse) { create(:warehouse) }
      let(:new_warehouse) { create(:warehouse) }
      let(:params) do
        {
          warehouse_id: warehouse.id,
          new_warehouse_id: new_warehouse.id
        }
      end

      it 'returns not_found code' do
        post('/products/1/transfer', params: params)
        expect(response.status).to eq(404)
      end
    end

    context 'when no warehouse with such id' do
      let(:new_warehouse) { create(:warehouse) }
      let(:product) { create(:product) }
      let(:params) do
        {
          warehouse_id: -1,
          new_warehouse_id: new_warehouse.id
        }
      end

      it 'returns not_found code' do
        post("/products/#{product.id}/transfer", params: params)
        expect(response.status).to eq(404)
      end
    end

    context 'when no new_warehouse with such id' do
      let(:warehouse) { create(:warehouse) }
      let(:product) { create(:product) }
      let(:params) do
        {
          warehouse_id: warehouse.id,
          new_warehouse_id: -1
        }
      end

      it 'returns not_found code' do
        post("/products/#{product.id}/transfer", params: params)
        expect(response.status).to eq(404)
      end
    end

    context 'when stocklist quantity is 0 and new_stocklist is nil' do
      let(:stocklist) { create(:stocklist, quantity: 0) }
      let(:new_warehouse) { create(:warehouse) }
      let(:params) do
        {
          warehouse_id: stocklist.warehouse.id,
          new_warehouse_id: new_warehouse.id,
          quantity: 20
        }
      end

      it "returns 422 error and don't transfer products", :aggregate_failures do
        post("/products/#{stocklist.product.id}/transfer", params: params)

        expect(response.status).to eq(422)
        expect(stocklist.reload.quantity).to eq(0)
        new_stocklist = Stocklist.find_by(product: stocklist.product, warehouse: new_warehouse)
        expect(new_stocklist).to eq(nil)
      end
    end

    context 'when stocklist quantity is 0 and new_stocklist is with some quantity' do
      let(:product) { create(:product) }
      let(:stocklist) { create(:stocklist, quantity: 0, product: product) }
      let(:new_stocklist) { create(:stocklist, quantity: 10, product: product) }
      let(:params) do
        {
          warehouse_id: stocklist.warehouse.id,
          new_warehouse_id: new_stocklist.warehouse.id,
          quantity: 20
        }
      end

      it "returns 422 error and don't transfer products", :aggregate_failures do
        post("/products/#{stocklist.product.id}/transfer", params: params)

        expect(response.status).to eq(422)
        expect(stocklist.reload.quantity).to eq(0)
        expect(new_stocklist.reload.quantity).to eq(10)
      end
    end

    context 'when warehouse quantity is enough and new_stocklist is nil' do
      let(:stocklist) { create(:stocklist, quantity: 20) }
      let(:new_warehouse) { create(:warehouse) }
      let(:params) do
        {
          warehouse_id: stocklist.warehouse.id,
          new_warehouse_id: new_warehouse.id,
          quantity: 20
        }
      end

      it 'transfer product from one warehouse to another', :aggregate_failures do
        post("/products/#{stocklist.product.id}/transfer", params: params)

        expect(response.status).to eq(204)
        new_stocklist = Stocklist.find_by(product: stocklist.product, warehouse: new_warehouse)
        expect(new_stocklist.quantity).to eq(20)
        expect(stocklist.reload.quantity).to eq(0)
      end
    end

    context 'when warehouse quantity is enough and new_stocklist is with some quantity' do
      let(:product) { create(:product) }
      let(:stocklist) { create(:stocklist, quantity: 20, product: product) }
      let(:new_stocklist) { create(:stocklist, quantity: 30, product: product) }
      let(:params) do
        {
          warehouse_id: stocklist.warehouse.id,
          new_warehouse_id: new_stocklist.warehouse.id,
          quantity: 10
        }
      end

      it 'transfer product from one warehouse to another', :aggregate_failures do
        post("/products/#{stocklist.product.id}/transfer", params: params)

        expect(response.status).to eq(204)
        expect(new_stocklist.reload.quantity).to eq(40)
        expect(stocklist.reload.quantity).to eq(10)
      end
    end

    context 'when quantity not passed' do
      let(:product) { create(:product) }
      let(:stocklist) { create(:stocklist, quantity: 20, product: product) }
      let(:new_stocklist) { create(:stocklist, quantity: 30, product: product) }
      let(:params) do
        {
          warehouse_id: stocklist.warehouse.id,
          new_warehouse_id: new_stocklist.warehouse.id
        }
      end

      it 'transfer all products from one warehouse to another', :aggregate_failures do
        post("/products/#{product.id}/transfer", params: params)
        expect(response.status).to eq(204)
        expect(new_stocklist.reload.quantity).to eq(50)
        expect(stocklist.reload.quantity).to eq(0)
      end
    end

    context 'when warehouse_id not passed' do
      let(:params) do
        {
          new_warehouse_id: 1
        }
      end

      it 'returns 400 error' do
        post('/products/1/transfer', params: params)

        expect(response.status).to eq(400)
      end
    end

    context 'when new_warehouse_id not passed' do
      let(:params) do
        {
          warehouse_id: 1
        }
      end

      it 'returns 400 error' do
        post('/products/1/transfer', params: params)

        expect(response.status).to eq(400)
      end
    end
  end

  describe 'POST /products/:id/sell', :aggregate_failures do
    context 'when no product with such id' do
      let(:stocklist) { create(:stocklist, quantity: 10) }
      let(:params) do
        {
          quantity: 10
        }
      end

      it 'returns 404 error' do
        post('/products/1/sell', params: params)

        expect(response.status).to eq(404)
      end
    end

    context 'when products in all warehouses is not enough' do
      let(:product) { create(:product) }
      let(:warehouse1) { create(:warehouse) }
      let(:warehouse2) { create(:warehouse) }
      let!(:stocklist1) { create(:stocklist, quantity: 4, product: product, warehouse: warehouse1) }
      let!(:stocklist2) { create(:stocklist, quantity: 5, product: product, warehouse: warehouse2) }
      let(:params) do
        {
          quantity: 10
        }
      end

      it "returns 422 error and don't sell products", :aggregate_failures do
        post("/products/#{product.id}/sell", params: params)

        expect(response.status).to eq(422)
        expect(JSON.parse(response.body)["error"]).to eq("not enough products")
        expect(warehouse1.reload.balance).to eq(0)
        expect(warehouse2.reload.balance).to eq(0)
        expect(stocklist1.reload.quantity).to eq(4)
        expect(stocklist2.reload.quantity).to eq(5)
      end
    end

    context 'when quantity is enough in one warehouse' do
      let(:product) { create(:product, price: 1_000) }
      let(:warehouse) { create(:warehouse) }
      let!(:stocklist) { create(:stocklist, quantity: 15, product: product, warehouse: warehouse) }
      let(:params) do
        {
          quantity: 10
        }
      end

      it 'sells products', :aggregate_failures do
        post("/products/#{product.id}/sell", params: params)

        expect(response.status).to eq(204)
        expect(stocklist.reload.quantity).to eq(5)
        expect(warehouse.reload.balance).to eq(10_000)
      end
    end

    context 'when quantity is enough in several warehouses' do
      let(:product) { create(:product, price: 1_000) }
      let(:warehouse1) { create(:warehouse) }
      let(:warehouse2) { create(:warehouse) }
      let!(:stocklist1) { create(:stocklist, quantity: 15, product: product, warehouse: warehouse1) }
      let!(:stocklist2) { create(:stocklist, quantity: 15, product: product, warehouse: warehouse2) }
      let(:params) do
        {
          quantity: 20
        }
      end

      it 'sells products', :aggregate_failures do
        post("/products/#{product.id}/sell", params: params)

        expect(response.status).to eq(204)
        expect(stocklist1.reload.quantity).to eq(0)
        expect(stocklist2.reload.quantity).to eq(10)
        expect(warehouse1.reload.balance).to eq(15_000)
        expect(warehouse2.reload.balance).to eq(5_000)
      end
    end

    context 'when quantity not passed' do
      let(:params) { {} }

      it 'returns 400 error' do
        post('/products/1/sell', params: params)

        expect(response.status).to eq(400)
      end
    end
  end
end
