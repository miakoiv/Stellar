# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# This path is needed by StyleGenerator to compile assets on demand
Rails.application.config.assets.paths << File.join(
  Rails.root, 'tmp', 'cache', 'assets'
)

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )

Rails.application.config.assets.precompile += %w(
  print.css
  jasny-bootstrap/rowlink.js
  payment_gateway/none.js
  payment_gateway/paybyway.js
  themes/birch.css       themes/birch.js
  themes/boutique.css    themes/boutique.js
  themes/cardirad.css    themes/cardirad.js
  themes/cards.css       themes/cards.js
  themes/cottage.css     themes/cottage.js
  themes/darkmatter.css  themes/darkmatter.js
  themes/hiustalo.css    themes/hiustalo.js
  themes/material.css    themes/material.js
  themes/mechanet.css    themes/mechanet.js
  themes/premium.css     themes/premium.js
  email/mailgun.css
  stellar.css
  devise.css
  admin.css
  hamburgers/hamburgers.css
  ckeditor5/ckeditor
  ckeditor5/translations/en
  ckeditor5/translations/fi
)
