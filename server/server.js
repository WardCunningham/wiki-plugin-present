// present plugin, server-side component
// These handlers are launched with the wiki server.

import fs from 'node:fs/promises'
import path from 'node:path'

const startServer = params => {
  const { app, argv } = params

  // where are going to look for peers
  const data = path.join(argv.data, '..')
  // base of peers
  const peerRoot = path.parse(argv.data).base.split('.').splice(1).join('.')

  const isPeer = entry => {
    const entryRoot = path.parse(entry.name).base.split('.').splice(1).join('.')
    if (peerRoot === entryRoot) {
      return true
    } else {
      return false
    }
  }

  const isWiki = entry => {
    const sitemapPath = path.join(entry.path, entry.name, 'status', 'sitemap.json')

    return new Promise(resolve => {
      fs.access(sitemapPath, fs.constants.R_OK)
        .then(() => {
          resolve(true)
        })
        .catch(() => {
          resolve(false)
        })
    })
  }

  const wikiPages = async entry => {
    const pagesPath = path.join(entry.path, entry.name, 'pages')

    return new Promise(resolve => {
      fs.readdir(pagesPath)
        .then(entries => {
          resolve({ site: entry.name, pages: entries.length })
        })
        .catch(() => {
          resolve({ site: entry.name, pages: 0 })
        })
    })
  }

  app.get('/plugin/present/roll', (req, res) => {
    fs.readdir(data, { withFileTypes: true })
      .then(entries => {
        // only interested in directories, where they are a peer
        return entries.filter(entry => {
          if (entry.isDirectory() && isPeer(entry)) {
            return true
          } else {
            return false
          }
        })
      })
      .then(async entries => {
        // only interested if the entry is a wiki
        const areWiki = await Promise.all(entries.map(isWiki))
        return entries.filter((item, index) => areWiki[index])
      })
      .then(async entries => {
        const roll = await Promise.all(entries.map(wikiPages))
        res.json({ roll })
      })
  })
}

export { startServer }
