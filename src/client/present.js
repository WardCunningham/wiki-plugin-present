const expand = text => {
  return text
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/\*(.+?)\*/g, '<i>$1</i>')
}
const elapsed = msec => {
  const interval = Math.floor(msec / 1000)
  const two = 1.9
  let text = 'a minute ago'
  if (interval > two * 60) text = `${Math.round(interval / 60)} minutes ago`
  if (interval > two * 60 * 60) text = `${Math.round(interval / (60 * 60))} hours ago`
  if (interval > two * 24 * 60 * 60) text = `${Math.round(interval / (24 * 60 * 60))} days ago`
  if (interval > two * 24 * 60 * 60 * 7) text = `${Math.round(interval / (24 * 60 * 60 * 7))} weeks ago`
  if (interval > two * 24 * 60 * 60 * 30) text = `${Math.round(interval / (24 * 60 * 60 * 30))} months ago`
  if (interval > two * 24 * 60 * 60 * 365) text = `${Math.round(interval / (24 * 60 * 60 * 365))} years ago`
  return text
}
const recent = sitemap => {
  if (!sitemap) return ''
  const dates = sitemap
    .map(page => page.date)
    .filter(el => {
      if (typeof el === 'number') {
        return true
      } else {
        return false
      }
    })
  if (dates.length === 0) return ''
  return elapsed(Date.now() - Math.max(...dates))
}

const emit = ($item, item) => {
  if ($item.closest('.page').hasClass('remote')) {
    $item.append(`
      <div style="background-color:#eee;padding:15px;">
        <center>
          ${expand(item.text)}
          <p class=caption>Presence is only available when viewed on a page's home wiki.</p>
        <table width=100%></table>
      </div>
    `)
  } else {
    $item.append(`
      <div style="background-color:#eee;padding:15px;">
        <center>
          ${expand(item.text)}
          <p class=caption>updating</p>
        <table width=100%></table>
      </div>
    `)

    const tick = () => {
      $item.find('.caption').text(`updated ${elapsed(Date.now() - $item.start)}`)
    }
    const render = data => {
      const rows = []
      const sufix = location.port in [80, '80', '', null] ? '' : `:${location.port}`
      for (const row of data.roll) {
        const sitemap = wiki.neighborhood['#{row.site}#{sufix}']?.sitemap
        if (row.pages > 0) {
          const name = row.site.split('.')[0]
          const link = `
            <img
            class=remote
            title=${row.site}${sufix}
            src=//${row.site}${sufix}/favicon.png
            data-site=${row.site}${sufix}
            data-slug=welcome-visitors>`
          rows.push(`
            <tr><td align=right>
              ${name} ${link}
            <td data-site=${row.site}${sufix}>
              ${row.pages} pages ${recent(sitemap)}`)
          wiki.neighborhoodObject.registerNeighbor(row.site + sufix)
        }
      }
      $item.find('table').html(rows.join('\n'))
      $item.find('.caption').text('just updated')

      clearInterval($item.ticker)
      $item.start = Date.now()
      $item.ticker = setInterval(tick, 60000)

      $('body').on('new-neighbor-done', (e, site) => {
        const $td = $item.find(` td[data-site="${site}"]`)
        if (!$td.length > 0) return
        const sitemap = wiki.neighborhood[site].sitemap
        $td.text(`${sitemap.length} pages ${recent(sitemap)}`)
      })

    }
    const trouble = xhr => {
      $item.find('p').html(xhr.responseJSON?.error || 'server error')
    }

    const update = () => {
      fetch('/plugin/present/roll')
        .then(response => {
          if (!response.status) {
            throw new Error(`HTTP error: ${response.status}`)
          }
          return response.json()
        })
        .then(data => {
          render(data)
        })
        .catch(error => {
          trouble(error)
        })
    }
    update()
    $item.find('.caption').on('click', () => update())
  }
}
const bind = ($item, item) => {
  $item.dblclick(() => {
    wiki.textEditor($item, item)
  })
}

if (typeof window !== 'undefined') {
  window.plugins.present = { emit, bind }
}

export const present = typeof window == 'undefined' ? { expand, elapsed } : undefined
