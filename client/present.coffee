
expand = (text)->
  text
    .replace /&/g, '&amp;'
    .replace /</g, '&lt;'
    .replace />/g, '&gt;'
    .replace /\*(.+?)\*/g, '<i>$1</i>'

elapsed = (msec) ->
  interval = Math.floor msec/1000
  two = 1.9
  text = "a minute ago"
  text = "#{Math.round interval/60} minutes ago" if interval > two*60
  text = "#{Math.round interval/(60*60)} hours ago" if interval > two*60*60
  text = "#{Math.round interval/(24*60*60)} days ago" if interval > two*24*60*60
  text = "#{Math.round interval/(24*60*60*7)} weeks ago" if interval > two*24*60*60*7
  text = "#{Math.round interval/(24*60*60*30)} months ago" if interval > two*24*60*60*30
  text = "#{Math.round interval/(24*60*60*365)} years ago" if interval > two*24*60*60*365
  text

recent = (sitemap) ->
    return '' unless sitemap
    dates = (page.date for page in sitemap)
    dates = dates.filter (date) -> date?
    return '' unless dates.length > 0
    elapsed Date.now()-Math.max(dates...)

emit = ($item, item) ->
  $item.append """
    <div style="background-color:#eee;padding:15px;">
      <center>
        #{expand item.text}
        <p class=caption>updating</p>
      <table width=100%></table>
    </div>
  """

  tick = ->
    $item.find('.caption').text "updated #{elapsed Date.now()-$item.start}"

  render = (data) ->
    console.log data
    rows = []
    sufix = if location.port in [80, '80', '', null] then '' else ":#{location.port}"
    for row in data.roll
      sitemap = wiki.neighborhood["#{row.site}#{sufix}"]?.sitemap
      if row.pages > 0
        name = row.site.split('.')[0]
        link = """
          <img
          class=remote
          title=#{row.site}#{sufix}
          src=//#{row.site}#{sufix}/favicon.png
          data-site=#{row.site}#{sufix}
          data-slug=welcome-visitors>"""
        rows.push """
          <tr><td align=right>
            #{name} #{link}
          <td data-site=#{row.site}#{sufix}>
            #{row.pages} pages #{recent sitemap}"""
        wiki.neighborhoodObject.registerNeighbor row.site + sufix
    $item.find('table').html(rows.join("\n"))
    $item.find('.caption').text "just updated"

    clearInterval $item.ticker
    $item.start = Date.now()
    $item.ticker = setInterval tick, 60000

    $('body').on 'new-neighbor-done', (e, site) ->
      $td = $item.find """td[data-site="#{site}"]"""
      return unless $td.length > 0
      sitemap = wiki.neighborhood[site].sitemap
      $td.text "#{sitemap.length} pages #{recent sitemap}"

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
module.exports = {expand, elapsed} if module?

