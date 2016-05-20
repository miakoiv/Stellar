jQuery ->

  # When the checkout form is submitted, collapse and reveal relevant
  # elements. Note that a payment widget will call this after verifying
  # a payment, by triggering submit on #checkout-form.
  $('#checkout-form').on 'ajax:success', (e, data, status, xhr) ->
    if data.paid
      $('#payment-widget').collapse 'hide'
      $('#confirm-button').collapse 'hide'
      $('#message-success').collapse 'show'
      $('#checkout-form').collapse 'show'
    else
      $('#checkout-form').find('fieldset').attr 'disabled', true
      $('#continue-button').collapse 'hide'
      $('#checkout-form').collapse 'hide'
      $('#payment-widget').collapse 'show'
