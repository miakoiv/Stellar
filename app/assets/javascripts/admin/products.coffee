# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

@update_markup_margin = ->
  trade_price = numbro().unformat $('#product_trade_price').val()
  retail_price = numbro().unformat $('#product_retail_price').val()
  markup_percent = 100 * (retail_price - trade_price) / trade_price
  margin_percent =   100 * (retail_price - trade_price) / retail_price
  $('#markup_percent').val numbro(markup_percent).format('0.00')
  $('#margin_percent').val numbro(margin_percent).format('0.00')
