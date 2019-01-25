$(document)
  .on 'show.bs.collapse', '#app-navbar', ->
    $('.navbar-toggle').addClass 'is-active'
  .on 'hide.bs.collapse', '#app-navbar', ->
    $('.navbar-toggle').removeClass 'is-active'
