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

  # When the checkout form is submitted, collapse and reveal relevant
  # elements. Note that shipping and payment gateways may call this by
  # triggering submit on #checkout-form.
  $('#checkout-form').on 'ajax:success', (e, data, status, xhr) ->
    $.do_checkout_phase data.checkout_phase
