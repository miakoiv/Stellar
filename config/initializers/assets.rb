# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

Rails.application.config.assets.paths << Rails.root.join('vendor', 'assets', 'paths')

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )

Rails.application.config.assets.precompile += %w(
  jasny-bootstrap/rowlink.js
  payment_gateway/paybyway.js
  spry_themes/alcoholic.css   spry_themes/alcoholic.js
  spry_themes/apprentice.css  spry_themes/apprentice.js
  spry_themes/birch.css       spry_themes/birch.js
  spry_themes/boutique.css    spry_themes/boutique.js
  spry_themes/budget.css      spry_themes/budget.js
  spry_themes/carbon.css      spry_themes/carbon.js
  spry_themes/cards.css       spry_themes/cards.js
  spry_themes/compass.css     spry_themes/compass.js
  spry_themes/fanletti.css    spry_themes/fanletti.js
  spry_themes/hiustalo.css    spry_themes/hiustalo.js
  spry_themes/lepola.css      spry_themes/lepola.js
  spry_themes/penumbra.css    spry_themes/penumbra.js
  spry_themes/premium.css     spry_themes/premium.js
  spry_themes/saarimedia.css  spry_themes/saarimedia.js
  spry_themes/solar.css       spry_themes/solar.js
  spry_themes/stellar.css     spry_themes/stellar.js
  email/mailgun.css
)
