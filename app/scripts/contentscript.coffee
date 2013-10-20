'use strict'

api = '//ws.audioscrobbler.com/2.0/?'
lfm = 'http://www.last.fm/api/auth/?'

key = 'f85dd881f328badc6505a31ae9cc8626'
secret = 'a0c50bb8ceda91e115c44b725680d904'

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

  request = new XMLHttpRequest()

  request.onreadystatechange = ->
    if request.readyState is 4 and request.status is 200
      response = JSON.parse(request.responseText)
      console.log response.track

  request.open 'GET', request
  request.send()

authorise = ->
  query =
    method: 'auth.gettoken'
    api_key: key
    format: 'json'

  request = new XMLHttpRequest()
  request.onreadystatechange = ->
    if request.readyState is 4 and request.status is 200
      response = JSON.parse(request.responseText)
      token = localStorage.token = response.token

      query =
        api_key: key
        token: token
      window.open lfm + buildQuery(query)

    else
      localStorage.token = ''

  request.open 'GET', api + buildQuery(query)
  request.send()

getSession = ->
  authorise() if not localStorage.token or localStorage.token is ''
  if localStorage.session and localStorage.session isnt ''
    return localStorage.session

  query =
    method: 'auth.getsession'
    api_key: key
    token: localStorage.token

  sig = sign(query)

  query.api_sig = sig
  query.format = 'json'

  request = new XMLHttpRequest()
  request.onreadystatechange = ->
    if request.readyState is 4 and request.status is 200
      response = JSON.parse(request.responseText)
      localStorage.session = response.session.key if response.session
  request.open 'GET', api + buildQuery(query)
  request.send()

sign = (query) ->
  keys = Object.keys(query).sort()

  for key, i in keys
    keys[i] = key + query[key]

  signed = keys.join('') + secret
  SparkMD5.hash(signed)

main = ->
  track = document.querySelector('.track')

  observer = new window.WebKitMutationObserver (mutations) ->
    mutations.forEach (mutation) ->
      getTrack() if mutation.target.innerText isnt ''

  observer.observe track,
    childList: true
    characterData: true
    subtree: true

getSession()
