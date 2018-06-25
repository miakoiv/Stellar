(function() {
  var $e_payment_path, $failure, $verify_path;

  $e_payment_path = $('#paybyway-data').data('payUrl');

  $verify_path = $('#paybyway-data').data('verifyUrl');

  $failure = function(error_type) {
    $('.working').collapse('hide');
    $('#message-failure').find('.alert').text($('#messages').data(error_type));
    $('#message-failure').collapse('show');
    $('button', '.pay-now-button').attr('disabled', false);
    return $('.pay-now-button').collapse('show');
  };

  $('#paybyway-creditcard-form').on('submit', function(e) {
    var request;
    e.preventDefault();
    $('button', '.pay-now-button').attr('disabled', true);
    $('.pay-now-button').collapse('hide');
    $('.working').collapse('show');
    $('#message-failure').collapse('hide');
    request = $.get($(this).attr('action'));
    return request.done(function(data) {
      var amount, cvc, error, expiry, number, token;
      try {
        token = data.token;
        amount = data.amount;
        if (token == null) {
          throw 'token request failure';
        }
        number = $('#number').val().replace(/ /g, '');
        expiry = $('#expiry').payment('cardExpiryVal');
        cvc = $('#cvc').val();
        request = $.post(data.payment_url, {
          token: token,
          amount: amount,
          currency: data.currency,
          card: number,
          exp_month: expiry.month < 10 ? '0' + expiry.month : expiry.month,
          exp_year: expiry.year,
          security_code: cvc
        });
        request.done(function(data) {
          var verification;
          verification = $.post($verify_path, {
            token: token
          });
          verification.done(function() {
            return $('#checkout-form').trigger('submit.rails');
          });
          return verification.fail(function() {
            return $failure('chargeError');
          });
        });
        return request.error(function(data) {
          return $failure('chargeError');
        });
      } catch (error1) {
        error = error1;
        return $failure('tokenRequestError');
      }
    });
  });

  $('.payment-button').on('click', function(e) {
    var request;
    request = $.get($e_payment_path, {
      selected: $(this).data('selected')
    });
    return request.done(function(data) {
      var error, form;
      try {
        form = $('<form></form>').attr('action', data.payment_url).attr('method', 'GET');
        $('body').append(form);
        return form.submit();
      } catch (error1) {
        error = error1;
        return $failure('tokenRequestError');
      }
    });
  });

}).call(this);
