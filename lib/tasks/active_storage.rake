namespace :storage do
  require 'csv'

  desc 'Parse paperclip files for active storage'
  task :parse, [:path] => :environment do |_, args|
    attributes = {
      CheckoutProduct => 'image',
      Activity => 'poster',
      Advertisement => 'poster'
    }

    folder = args[:path] || 'public/images'
    originals = Dir["#{ folder.chomp('/') }/*/*/original.*"].map { |f| [f, f.split('/')[-3].capitalize.singularize, f.split('/')[-2]] }

    originals.each do |path, object_type, object_id|
      puts "\n#{ path }"

      # underscore messes with the constantize and capitalize
      object_type = 'CheckoutProduct' if object_type == 'Checkout_product'
      object = object_type.constantize.find_by_id(object_id)

      if object.nil?
        puts "-> [unknown] #{ object_type }(#{ object_id }) not found"
        next
      end

      File.open(path) do |file|
        object.instance_eval(attributes[object_type.constantize]).attach(
          io: file,
          filename: File.basename(path)
        )
      end

      puts '-> [stored]'
    end
  end
end
