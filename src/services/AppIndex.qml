pragma Singleton

import QtQuick
import Quickshell

Singleton {
  id: root

  property var applications: []
  property int maxResults: 80

  function refreshApplications() {
    applications = DesktopEntries.applications.values || []
  }

  function tokenize(text) {
    return (text || "").toLowerCase().trim().split(/[\s\-_\.]+/).filter(w => w.length > 0)
  }

  function wordBoundaryMatch(text, query) {
    const textWords = tokenize(text)
    const queryWords = tokenize(query)

    if (queryWords.length === 0 || queryWords.length > textWords.length)
      return false

    for (let i = 0; i <= textWords.length - queryWords.length; i++) {
      let ok = true
      for (let j = 0; j < queryWords.length; j++) {
        if (!textWords[i + j].startsWith(queryWords[j])) {
          ok = false
          break
        }
      }
      if (ok) return true
    }

    return false
  }

  function scoreApp(app, q) {
    const name = (app.name || "").toLowerCase()
    const genericName = (app.genericName || "").toLowerCase()
    const comment = (app.comment || "").toLowerCase()
    const id = (app.id || "").toLowerCase()
    const keywords = (app.keywords || []).map(k => (k || "").toLowerCase())

    if (name === q) return 10000
    if (name.startsWith(q)) return 5000
    if (wordBoundaryMatch(name, q)) return 3000
    if (name.includes(q)) return 1200
    if (genericName.startsWith(q)) return 800
    if (genericName.includes(q)) return 400
    if (id.includes(q)) return 300

    for (const k of keywords) {
      if (k.startsWith(q)) return 250
      if (k.includes(q)) return 100
    }

    if (comment.includes(q)) return 80
    return 0
  }

  function search(query) {
    const q = (query || "").trim().toLowerCase()

    let items = (applications || []).filter(app => {
      if (!app) return false
      if (app.noDisplay === true) return false
      return !!(app.name && (app.execString || app.exec || app.id))
    })

    if (!q) {
      return items.slice(0, maxResults)
    }

    const scored = []
    for (const app of items) {
      const score = scoreApp(app, q)
      if (score > 0) scored.push({ app, score })
    }

    scored.sort((a, b) => b.score - a.score)
    return scored.slice(0, maxResults).map(v => v.app)
  }

  Connections {
    target: DesktopEntries
    function onApplicationsChanged() {
      root.refreshApplications()
    }
  }

  Component.onCompleted: refreshApplications()
}
