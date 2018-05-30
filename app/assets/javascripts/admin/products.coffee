# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

@taxation = ->
  tax_categories = $('#product_tax_category_id').data 'taxCategories'
  tax_categories[$('#product_tax_category_id').val()]
@incl_tax = ->
  taxation().incl_tax
@tax_rate = ->
  taxation().rate

@update_trade_price_with_tax = ->
  trade_price = numbro().unformat $('#product_trade_price').val()
  trade_price_with_tax = trade_price * (100 + tax_rate()) / 100
  $('#product_trade_price_with_tax').val numbro(trade_price_with_tax).format('0.00')

@update_markup_margin = ->
  trade_price = numbro().unformat if incl_tax() then $('#product_trade_price_with_tax').val() else $('#product_trade_price').val()
  retail_price = numbro().unformat $('#product_retail_price').val()
  markup_percent = 100 * (retail_price - trade_price) / trade_price
  margin_percent =   100 * (retail_price - trade_price) / retail_price
  $('#markup_percent').val numbro(markup_percent).format('0.00')
  $('#margin_percent').val numbro(margin_percent).format('0.00')
