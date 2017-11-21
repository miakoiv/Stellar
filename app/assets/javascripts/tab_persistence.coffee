@persist_tabs = (key) ->
  settings = Cookies.getJSON('tab_settings') or {}
  tab = settings[key]
  if tab? then $("[href='#{tab}']").tab 'show'

jQuery ->
  $(document).on 'shown.bs.tab', (e) ->
    tab = $(e.target).attr 'href'
    key = $(e.target).parents('ul')[0].id
    settings = Cookies.getJSON('tab_settings') or {}
    settings[key] = tab
    Cookies.set 'tab_settings', settings
