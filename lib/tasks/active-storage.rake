namespace :storage do
  require 'csv'

  desc 'Parse paperclip files for active storage'
  task :read, [:path] => :environment do |_, args|
    attributes = {
      CheckoutProduct => 'image',
      Activity => 'poster',
      Advertisement => 'poster'
    }

    folder = args[:path] || 'public/images'
    originals = Dir["#{folder.chomp('/')}/*/*/original.*"].map{ |f| [f, f.split('/')[-3].capitalize.singularize, f.split('/')[-2]]}
    filenames = CSV.read("#{folder.chomp('/')}/filenames.csv").map{ |object_type, object_id, filename| ["#{object_type.strip}-#{object_id.strip}", filename] }.to_h

    puts "[info] loaded #{filenames.count} filenames"

    originals.each do |path, object_type, object_id|

      # underscore messes with the constantize and capitalize
      object_type = 'CheckoutProduct' if object_type == 'Checkout_product'
      object = object_type.constantize.find_by_id(object_id)

      if object.nil?
        puts "[skipped] #{path}"
        next
      end

      file = File.open(path)
      puts object.instance_eval(attributes[object_type.constantize]).attach(
        io: file,
        filename: filenames["#{object_type.downcase}-#{object_id}"] || File.basename(path)
      )

      puts "[stored] #{path}"
    end
  end
end
