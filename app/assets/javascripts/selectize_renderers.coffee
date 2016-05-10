$.fn.selectize.renderers =
  item: (item, escape) ->
    '<div><strong>' + escape(item.title) + '</strong> ' + (if item.subtitle then escape(item.subtitle) else '') + '</div>'
  option: (item, escape) ->
    '<div class="list-group-item"><div class="media-left"><div class="box-thumbnail">' + item.image_html + '</div></div><div class="media-body"><div><strong>' + escape(item.title) + ' </strong>' + (if item.subtitle then escape(item.subtitle) else '') + '</div><div class="small text-right">' + escape(item.code) + '</div></div></div>'
