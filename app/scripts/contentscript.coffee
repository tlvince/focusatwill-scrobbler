'use strict'

api = '//ws.audioscrobbler.com/2.0/?'
lfm = 'http://www.last.fm/api/auth/?'

key = 'f85dd881f328badc6505a31ae9cc8626'
secret = 'a0c50bb8ceda91e115c44b725680d904'

buildQuery = (query) ->
  str = []
  for key, value of query
    str.push "#{key}=#{encodeURIComponent(value)}"
  str.join '&'

sign = (query) ->
  keys = Object.keys(query).sort()

  for key, i in keys
    keys[i] = key + query[key]

  signed = keys.join('') + secret
  SparkMD5.hash(signed)

getTrack = ->
  artist = document.querySelector('.artist')
  track = document.querySelector('.track')

  artist = artist.textContent.replace(/^By: /, '').trim()
  track = track.textContent.trim()

  nowSeconds = parseInt(new Date().getTime() / 1000)

  track =
    artist: artist
    track: track
    timestamp: nowSeconds

getToken = (cb) ->
  query =
    method: 'auth.gettoken'
    api_key: key
    format: 'json'

  request = new XMLHttpRequest()
  request.onreadystatechange = ->
    if request.readyState is 4 and request.status is 200
      response = JSON.parse(request.responseText)
      if response.token
        _query =
          api_key: key
          token: response.token
        window.open lfm + buildQuery(_query)
        cb(response.token)

  request.open 'GET', api + buildQuery(query)
  request.send()

getSession = (token, cb) ->
  query =
    method: 'auth.getsession'
    api_key: key
    token: token
  query.api_sig = sign(query)
  query.format = 'json'

  request = new XMLHttpRequest()
  request.onreadystatechange = ->
    if request.readyState is 4 and request.status is 200
      response = JSON.parse(request.responseText)
      cb(response.sesson) if response.session

  request.open 'GET', api + buildQuery(query)
  request.send()

main = ->
  track = document.querySelector('.track')
  prevTrack = {}

  observer = new window.WebKitMutationObserver (mutations) ->
    mutations.forEach (mutation) ->
      if mutation.target.innerText isnt ''
        track = getTrack()
        nowPlaying(track)
        scrobble(track) if prevTrack.track
        prevTrack = track

  observer.observe track,
    childList: true
    characterData: true
    subtree: true

nowPlaying = (track) ->
  query =
    method: 'track.updateNowPlaying'
    artist: track.artist
    track: track.track
    api_key: key
    token: localStorage.lfmToken
    sk: localStorage.lfmSession

  query.api_sig = sign(query)
  query.format = 'json'

  request = new XMLHttpRequest()
  request.open 'POST', api + buildQuery(query)
  request.send()

scrobble = (track) ->
  query =
    method: 'track.scrobble'
    artist: track.artist
    track: track.track
    timestamp: track.timestamp
    api_key: key
    token: localStorage.lfmToken
    sk: localStorage.lfmSession

  query.api_sig = sign(query)
  query.format = 'json'

  request = new XMLHttpRequest()
  request.open 'POST', api + buildQuery(query)
  request.send()

unless localStorage.lfmToken
  getToken (token) ->
    localStorage.lfmToken = token

unless localStorage.lfmSession
  getSession localStorage.lfmToken, (session) ->
    localStorage.lfmSession = session.key

main()
