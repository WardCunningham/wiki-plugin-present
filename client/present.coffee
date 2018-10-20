
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
        <p class=caption>updating</p>
      <table width=70%></table>
    </div>
  """

  tick = ->
    elapsed = Math.floor (Date.now()-$item.start)/1000
    two = 1.9
    text = "updated a minute ago"
    text = "updated #{Math.round elapsed/60} minutes ago" if elapsed > two*60
    text = "updated #{Math.round elapsed/(60*60)} hours ago" if elapsed > two*60*60
    text = "updated #{Math.round elapsed/(24*60*60)} days ago" if elapsed > two*24*60*60
    $item.find('.caption').text text

  render = (data) ->
    console.log data
    rows = []
    sufix = if location.port == 80 then '' else ":#{location.port}"
    for row in data.roll
      if row.pages > 0
        name = row.site.split('.')[0]
        link = """<img
          class=remote
          title=#{row.site}#{sufix}
          src=//#{row.site}#{sufix}/favicon.png
          data-site=#{row.site}#{sufix}
          data-slug=welcome-visitors>
          #{name}"""
        rows.push "<tr><td>#{link}<td>#{row.pages} pages"
        wiki.neighborhoodObject.registerNeighbor row.site + sufix
    $item.find('table').html(rows.join("\n"))
    $item.find('.caption').text "just updated"
    clearInterval $item.ticker
    $item.start = Date.now()
    $item.ticker = setInterval tick, 60000

  trouble = (xhr) -> 
    $item.find('p').html xhr.responseJSON?.error || 'server error'
 
  update = ->
    $.ajax
      url: '/plugin/present/roll'
      dataType: 'json'
      success: render
      error: trouble

  update()
  $item.find('.caption').click -> update()

bind = ($item, item) ->
  $item.dblclick ->
    wiki.textEditor $item, item

window.plugins.present = {emit, bind} if window?
module.exports = {expand} if module?

