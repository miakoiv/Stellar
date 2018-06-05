# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$.fn.extend
  fetch_context: ->
    $.ajax
      type: 'GET'
      url: this.data 'url'
      data:
        gid: this.data 'gid'
