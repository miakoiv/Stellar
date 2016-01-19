$e_payment_path = $('#paybyway-data').data 'payUrl'
$verify_path = $('#paybyway-data').data 'verifyUrl'

$failure = (error_type) ->
  $('.working').collapse 'hide'
  $('#message-failure').find('.alert').text $('#messages').data(error_type)
  $('#message-failure').collapse 'show'
  $('button', '.pay-now-button').attr 'disabled', false
  $('.pay-now-button').collapse 'show'

$('#paybyway-creditcard-form').on 'submit', (e) ->
  e.preventDefault()
  $('button', '.pay-now-button').attr 'disabled', true
  $('.pay-now-button').collapse 'hide'
  $('.working').collapse 'show'
  $('#message-failure').collapse 'hide'
  request = $.get $(this).attr 'action'
  request.done (data) ->
    try
      token = data.token
      amount = data.amount
      throw 'token request failure' unless token?
      number = $('#number').val().replace(/ /g, '')
      expiry = $('#expiry').payment 'cardExpiryVal'
      cvc = $('#cvc').val()
      request = $.post data.payment_url,
        token: token
        amount: amount
        currency: data.currency
        card: number
        exp_month: if expiry.month < 10 then '0' + expiry.month else expiry.month
        exp_year: expiry.year
        security_code: cvc
      request.done (data) ->
        verification = $.post $verify_path, token: token
        verification.done ->
          $('#checkout-form').trigger 'submit.rails'
        verification.fail ->
          $failure 'chargeError'
      request.error (data) ->
        $failure 'chargeError'
    catch error
      $failure 'tokenRequestError'

$('.bank-button').on 'click', (e) ->
  request = $.get $e_payment_path,
    selected: $(this).data 'selected'
  request.done (data) ->
    try
      form = $('<form></form>').attr('action', data.payment_url).attr('method', 'GET')
      $('body').append form
      form.submit()
    catch error
      $failure 'tokenRequestError'
