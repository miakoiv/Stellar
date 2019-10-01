# Collapse and reveal checkout panels according to checkout phase.

$.doCheckoutPhase = (phase) ->
  ga?('send', 'pageview', '/checkout' + phase)
  switch phase
    when 'address'
      $('#shipping-panel, #payment-panel, #confirm-panel, #complete-panel').collapse 'hide'
      $('#address-panel').collapse 'show'
    when 'shipping'
      $('#address-panel, #payment-panel, #confirm-panel, #complete-panel').collapse 'hide'
      $('#shipping-panel').collapse 'show'
    when 'payment'
      if payment_methods_url = $('#payment-methods').data('url')
        $.get payment_methods_url
      $('#address-panel, #shipping-panel, #confirm-panel, #complete-panel').collapse 'hide'
      $('#payment-panel').collapse 'show'
    when 'confirm'
      $('#address-panel, #shipping-panel, #payment-panel, #complete-panel').collapse 'hide'
      $('#confirm-panel').collapse 'show'
    when 'complete'
      $('#address-panel, #shipping-panel, #confirm-panel, #payment-panel').collapse 'hide'
      $('#complete-panel').collapse 'show'

jQuery ->

  window.smoothScroll = new SmoothScroll

  # This callback is triggered by user submission of #checkout-form, and
  # externally by actions that create shipments or payments.
  $('#checkout-form')
    .on 'ajax:success', (e, data, status, xhr) ->
      $.doCheckoutPhase data.checkout_phase
    .on 'ajax:error', (e, xhr, status, error) ->
      $('#order-preflight-modal').modal 'show'

  # Event handlers to make the shown panel primary and scroll it into view,
  # and revert hidden panels back to default appearance.
  $(document).on 'shown.bs.collapse', '#checkout-panels .panel-collapse:not(.active)', (e) ->
    $t = $(this)
    $p = $t.parents '.panel'
    $t.addClass 'active'
    $p.removeClass 'panel-default'
    $p.addClass 'panel-primary'
    window.smoothScroll.animateScroll $p[0], null, {header: '#main-nav', speed: 300, updateURL: false}

  $(document).on 'hide.bs.collapse', '#checkout-panels .panel-collapse.active', (e) ->
    $t = $(this)
    $p = $t.parents '.panel'
    $t.removeClass 'active'
    $p.removeClass 'panel-primary'
    $p.addClass 'panel-default'
