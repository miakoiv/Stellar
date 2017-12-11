$('#none-confirm-form').on 'submit', (e) ->
  e.preventDefault()
  request = $.post $(this).attr 'action'
  request.done (data) ->
    $('#checkout-form').trigger 'submit.rails'
