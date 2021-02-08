product1 = FactoryBot.create(:product)
product2 = FactoryBot.create(:product)

warehouse1 = FactoryBot.create(:warehouse)
warehouse2 = FactoryBot.create(:warehouse)
warehouse3 = FactoryBot.create(:warehouse)
warehouse4 = FactoryBot.create(:warehouse)

stocklist1 = FactoryBot.create(:stocklist, product: product1, warehouse: warehouse1, quantity: 10)
stocklist2 = FactoryBot.create(:stocklist, product: product1, warehouse: warehouse2, quantity: 10)
stocklist3 = FactoryBot.create(:stocklist, product: product2, warehouse: warehouse3, quantity: 10)
stocklist4 = FactoryBot.create(:stocklist, product: product2, warehouse: warehouse4, quantity: 10)
