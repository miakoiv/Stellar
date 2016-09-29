# Collapse and reveal checkout panels according to checkout phase.

$.do_checkout_phase = (phase) ->
  switch phase
    when 'address'
      $('#shipping-panel, #payment-panel, #complete-panel').collapse 'hide'
      $('#address-panel').collapse 'show'
    when 'shipping'
      $('#address-panel, #payment-panel, #complete-panel').collapse 'hide'
      $('#shipping-panel').collapse 'show'
    when 'payment'
      $('#address-panel, #shipping-panel, #complete-panel').collapse 'hide'
      $('#payment-panel').collapse 'show'
    when 'complete'
      $('#address-panel, #shipping-panel, #payment-panel').collapse 'hide'
      $('#complete-panel').collapse 'show'

jQuery ->

  # This callback is triggered by user submission of #checkout-form, and
  # externally by actions that create shipments or payments.
  $('#checkout-form').on 'ajax:success', (e, data, status, xhr) ->
    $.do_checkout_phase data.checkout_phase
