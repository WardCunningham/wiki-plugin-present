
expand = (text)->
  text
    .replace /&/g, '&amp;'
    .replace /</g, '&lt;'
    .replace />/g, '&gt;'
    .replace /\*(.+?)\*/g, '<i>$1</i>'

emit = ($item, item) ->
  $item.append """
    <div style="background-color:#eee;padding:15px;">
      <center>
        #{expand item.text}
        <p class=caption>just updated</p>
      <table width=70%></table>
    </div>
  """

  start = Date.now()
  tick = ->
    elapsed = Math.floor (Date.now()-start)/60000
    $item.find('.caption').text "updated #{elapsed} minutes ago"
  setInterval tick, 60000

  render = (data) ->
   console.log data

   user = (site) ->
    name = site.split('.')[0]
    "<img width=16 src=//#{site}/favicon.png> #{name}"

   rows = ("<tr><td>#{user row.site}<td>#{row.pages} pages" for row in data.roll)
   $item.find('table').empty().html(rows.join("\n"))

  trouble = (xhr) -> 
    $item.find('p').html xhr.responseJSON?.error || 'server error'
 
  $.ajax
    url: '/plugin/present/roll'
    dataType: 'json'
    success: render
    error: trouble

bind = ($item, item) ->
  $item.dblclick ->
    wiki.textEditor $item, item

window.plugins.present = {emit, bind} if window?
module.exports = {expand} if module?

