#encoding: utf-8

namespace :styles do
  desc "Recompile store styles to include changes made to theme files"
  task recompile: :environment do |task, args|
    Store.all.each do |store|
      if store.style.present?
        puts "Recompiling style for #{store}"
        Styles::Generator.new(store.theme, store.style).compile
      end
    end
  end
end
