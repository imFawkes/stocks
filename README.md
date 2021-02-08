# README
Ruby vesion 2.7.2, Rails version 6.1.1

## How to test:

Clone app:
<br /> `git clone https://github.com/imFawkes/stocks_api <directory>`

Add gems:
<br /> `bundle install`

Setup DB:
<br /> `rails db:setup`

Run server in one terminal window:
<br /> `rails s`

### Use `curl` in anoter terminal window to test:

transfer products from one warehouse to another:
<br /> `curl -i -d '{"warehouse_id":"1", "new_warehouse_id":"2", "quantity":"5"}' -H "Content-Type: application/json" -X POST http://localhost:3000/products/1/transfer`

sell products with passed quantity:
<br /> `curl -i -d '{"product_id":"2", "quantity":"5"}' -H "Content-Type: application/json" -X POST http://localhost:3000/products/2/sell`
