jQuery ->

  # When the checkout form is submitted, collapse and reveal relevant
  # elements. Note that shipping and payment gateways may call this by
  # triggering submit on #checkout-form.
  $('#checkout-form').on 'ajax:success', (e, data, status, xhr) ->
    $('#checkout-form').find('fieldset').attr 'disabled', true
    switch data.status
      when 'address'
        $('#checkout-form').find('fieldset').attr 'disabled', false
        $('#shipping-panel, #payment-panel, #confirm-panel').collapse 'hide'
        $('#address-panel').collapse 'show'
      when 'shipping'
        $('#address-panel, #payment-panel, #confirm-panel').collapse 'hide'
        $('#shipping-panel').collapse 'show'
      when 'payment'
        $('#address-panel, #shipping-panel').collapse 'hide'
        $('#payment-panel').collapse 'show'
      when 'confirm'
        $('#address-panel, #shipping-panel, #payment-panel').collapse 'hide'
        $('#confirm-panel').collapse 'show'
      when 'complete'
        $('#address-panel, #shipping-panel, #payment-panel, #confirm-order').collapse 'hide'
        $('#message-success').collapse 'show'
