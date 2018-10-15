
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
    rows = []
    for row in data.roll
      if row.pages > 0
        name = row.site.split('.')[0]
        link = """<img class=remote title=#{row.site} src=//#{row.site}/favicon.png data-site=#{row.site} data-slug=welcome-visitors> #{name}"""
        rows.push "<tr><td>#{link}<td>#{row.pages} pages"
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

