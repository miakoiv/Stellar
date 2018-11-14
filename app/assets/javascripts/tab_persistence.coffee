@persist_tabs = (key) ->
  settings = Cookies.getJSON('tab_settings') or {}
  tab = settings[key]
  if tab?
    $tab = $("[href='#{tab}']")
    $tab.tab 'show'

$(document).on 'shown.bs.tab', (e) ->
  $tab = $(e.target)
  tab = $tab.attr 'href'
  return unless tab?
  key = $tab.parents('ul')[0].id
  settings = Cookies.getJSON('tab_settings') or {}
  settings[key] = tab
  Cookies.set 'tab_settings', settings
