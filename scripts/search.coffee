# Description:
#   Example scripts for you to examine and try out.
#
# Notes:
#   They are commented out by default, because most of them are pretty silly and
#   wouldn't be useful and amusing enough for day to day huboting.
#   Uncomment the ones you want to try and experiment with.
#
#   These are from the scripting documentation: https://github.com/github/hubot/blob/master/docs/scripting.md

cheerio = require 'cheerio'
decode = require 'ent/decode'
url = require 'url'

kChromeUserAgent = 
  'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_5) AppleWebKit/537.36 (KHTML,
  like Gecko) Chrome/43.0.2313.0 Safari/537.36'

striptags = (str) ->
  # A regex will work for simple cases.
  return str.replace(/(<([^>]+)>)/ig, '')

getText = ($) ->
  # Try for a top search result panel.
  # Using the ._Tgc class is a hack, the class could change
  elem = $('span._Tgc')
  if elem.length > 0
    return decode striptags elem.html()

  # Try for an answer panel.
  # Using the ._eF class is a hack, the class could change
  elem = $('._eF')
  if elem.length > 0
    return decode striptags elem.html()

  # Try for an vk answer.
  elem = $('div.vk_ans')
  if elem.length > 0
    return decode striptags elem.html()

  # Try for conversion answer.
  elem = $('#rhs_div input.ucw_data')
  if elem.length > 0
    return elem.attr 'value'

  # Try for maps text.
  elem = $('span._Abe')
  if elem.length > 0
    return decode striptags elem.html()

  # Try for a knowledge panel.  Should always do this last if we can't find 
  # else more relevant anything.
  elem = $('div.kno-rdesc span')
  if elem.length > 0
    return decode striptags elem.html()

  return null


getImage = ($) ->
  # Try for image
  elem = $('a.bia.uh_rl')
  if elem.length > 0
    return url.parse(elem.attr('href'), true).query.imgurl

  # Try for maps image
  elem = $('img.lu_vs.rremi')
  if elem.length > 0
    return "http://www.google.com/#{elem.attr('data-bsrc')}"

  return null


getVideo = ($) ->
  # Test for a video block YouTube video.
  elem = $('div.knowledge-block__video-nav-block cite')
  if elem.length > 0
    return "http://#{elem.text()}"

  # Test for a song block YouTube video.
  elem = $('div.knowledge-block__song-block cite')
  if elem.length > 0
    return "http://#{elem.text()}"

  return null

module.exports = (robot) ->

  robot.respond /(.*)/i, (msg) ->
    query = msg.match[1].split(' ').join('+')
    searchUrl = "https://www.google.com/search?q=#{query}"
    msg.http(searchUrl)
      .header('User-Agent', kChromeUserAgent)  # Used to return knowledge panels
      .get() (err, res, body) ->
        $ = cheerio.load body

        text = getText($)
        image = getImage($)
        video = getVideo($)

        if video
          msg.send video
        if !video and image
          msg.send image
        if text
          msg.send text
        msg.send searchUrl
