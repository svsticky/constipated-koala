class CreateCheckoutProductTypesFromProducts < ActiveRecord::Migration[5.1]
  # Migreer alle verschillende CheckoutProducts naar precies 1
  # CheckoutProductType per 'echt product'.
  def up
    # We beginnen met een lijst van alle bestaande producten, en pakken de
    # nieuwste, om de parent-relaties niet te missen.
    puts '--- Beginning creation of CheckoutProducts to CheckoutProductTypes ---'
    cps = CheckoutProduct
          .all
          .order(id: :desc)
          .to_a

    # We pakken steeds het nieuwste product, en alle ancestors (parents,
    # (parents van)+ parents) van het product.
    # Deze verwijderen we uit de lijst.
    while cps.any?
      p = cps.first
      cps.delete p
      lineage = [p]

      if p.parent
        ancestor = p.parent
        while ancestor
          cps.delete ancestor
          lineage << ancestor
          ancestor = ancestor.parent
        end
      end

      puts "--- Migrating #{ p.name } and #{ lineage.count - 1 } ancestors"

      # Als de migratie voor whatever reason twee keer loopt doen we niks
      next if p.checkout_product_type
      # Maak voor de hele lineage een CheckoutProductType:
      cpt = CheckoutProductType.new

      cpt.name      = p.name
      cpt.category  = p.category
      cpt.active    = p.active # Alleen de nieuwste kan actief zijn, lekker makkelijk
      cpt.price     = p.price
      cpt.image     = p.image
      cpt.skip_image_validation = true
      cpt.save!

      puts 'CPT created.'

      # Sla het CPT op bij de hele lineage van p als opvolger
      lineage.each do |voorouder|
        voorouder.checkout_product_type = cpt
        voorouder.skip_image_validation = true
        voorouder.save!
      end

      puts 'Lineage linked to CPT.'
    end
  end

  def down
    # No-op
  end
end
