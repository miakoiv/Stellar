namespace :images do

  desc "Upload image from file"
  task :upload, [:store, :path, :file] => :environment do |task, args|
    store = Store.find_by name: args.store
    image = store.images.find_or_initialize_by(attachment_file_name: args.file)
    image.attachment = File.new("#{args.path}/#{args.file}")
    image.save!
  end

  desc "Upload product image by EAN"
  task :product_ean, [:store, :path, :file] => :environment do |task, args|
    store = Store.find_by name: args.store

    # Filenames begin with a 13-digit product code.
    file = File.absolute_path(args.file, args.path)
    code = /\A\d+/.match(args.file).to_s

    # Copy the file into a tempfile to ensure paperclip can unlink it.
    tmp = Tempfile.new(code)
    tmp.write(File.read(file))

    # Store image by filename, whether it will be used or not.
    image = store.images.find_or_initialize_by(attachment_file_name: args.file)
    image.attachment = tmp
    image.save!
    puts "[i] %s" % args.file

    # Find matching product and replace its cover picture.
    product = store.products.find_by code: code
    if product
      pictures = product.pictures.presentational
      pictures.destroy_all
      pictures.create(image: image)
      puts "[p] %s %s" % [code, product]
    else
      warn "err %s not found" % code
    end
  end
end
