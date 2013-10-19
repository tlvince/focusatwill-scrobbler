'use strict'

api = '//ws.audioscrobbler.com/2.0/?'

buildQuery = (query) ->
  str = []
  for i of query
    str.push i + '=' + encodeURIComponent(query[i])
  str.join '&'

getTrack = ->
  artist = document.querySelector('.artist')
  track = document.querySelector('.track')

  artist = artist.textContent.replace(/^By: /, '').trim()
  track = track.textContent.trim()

  lfm =
    method: 'track.getInfo'
    api_key: 'f85dd881f328badc6505a31ae9cc8626'
    artist: artist
    track: track
    format: 'json'

  query = buildQuery(lfm)
  request = api + query

  httpRequest = new XMLHttpRequest()

  httpRequest.onreadystatechange = ->
    if httpRequest.readyState is 4
      if httpRequest.status is 200
        response = JSON.parse(httpRequest.responseText)
        console.log response.track

  httpRequest.open 'GET', request
  httpRequest.send()

track = document.querySelector('.track')

observer = new window.WebKitMutationObserver (mutations) ->
  mutations.forEach (mutation) ->
    getTrack() if mutation.target.innerText isnt ''

observer.observe track,
  childList: true
  characterData: true
  subtree: true
