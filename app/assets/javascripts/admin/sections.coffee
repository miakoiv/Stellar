# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'click', '.copy-section', ->
  key = 'store_#{current_store.slug}_section_pasteboard'
  $.get $(this).data 'url'
    .done (data) ->
      serialized = JSON.stringify data
      localStorage.setItem key, serialized

$(document).on 'click', '.paste-section', ->
  key = 'store_#{current_store.slug}_section_pasteboard'
  serialized = localStorage.getItem key
  if serialized
    $.ajax
      type: 'POST'
      dataType: 'script'
      url: $(this).data 'url'
      data: serialized
      contentType: 'application/json; charset=utf-8'
