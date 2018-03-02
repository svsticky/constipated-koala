class MigrateItemColumnToCheckoutTransactionItems < ActiveRecord::Migration[5.1]
  def change
    # Yeah leguiddit lekker itereren over alle transacties ooit gemaakt die items hebben
    puts '--- Beginning conversion of `items` column to CheckoutTransactionItem'

    ts = CheckoutTransaction
      .where.not(items: nil)

    puts "Migrating #{ts.count} transactions."

    ts.each do |t|
      # Boom yo Big Shaq voor elk item maken we een CheckoutTransactionItem aan
      t.items.each do |item|
        # Voor ieder item linken we de transactie aan het CPT, en nemen we de
        # prijs over van het product zoals hij toen was. `item` is een integer.
        p = CheckoutProduct.find item

        cti = CheckoutTransactionItem.new
        cti.checkout_transaction = t
        cti.checkout_product_type = p.checkout_product_type
        cti.price = p.price

        cti.save!
      end
    end
  end
end
