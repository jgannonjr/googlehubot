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

kChromeUserAgent = 
  'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_5) AppleWebKit/537.36 (KHTML,
  like Gecko) Chrome/43.0.2313.0 Safari/537.36'

striptags = (str) ->
  # A regex will work for simple cases.
  return str.replace(/(<([^>]+)>)/ig, '')

module.exports = (robot) ->

  robot.respond /(.*)/i, (msg) ->
    query = msg.match[1].split(' ').join('+')
    searchUrl = "https://www.google.com/search?q=#{query}"
    msg.http(searchUrl)
      .header('User-Agent', kChromeUserAgent)  # Used to return knowledge panels
      .get() (err, res, body) ->
        $ = cheerio.load body

        text = ''
        video = ''

        # Try for an answer panel.
        # Using the ._eF class is a hack, the class could change
        elem = $('._eF')
        if !text and elem.length > 0
          text = decode striptags elem.html()

        # Try for an vk answer.
        elem = $('div.vk_ans')
        if !text and elem.length > 0
          text = decode striptags elem.html()

        # Try for conversion answer.
        elem = $('#rhs_div input.ucw_data')
        if !text and elem.length > 0
          text = elem.attr 'value'

        # Try for a top search result panel.
        # Using the ._Tgc class is a hack, the class could change
        elem = $('span._Tgc')
        if !text and elem.length > 0
          text = decode striptags elem.html()

        # Try for a knowledge panel.
        elem = $('div.kno-rdesc span')
        if !text and elem.length > 0
          text = decode striptags elem.html()

        # Test for a video block YouTube video.
        elem = $('div.knowledge-block__video-nav-block cite')
        if !video and elem.length > 0
          video = "http://#{elem.text()}"

        # Test for a song block YouTube video.
        elem = $('div.knowledge-block__song-block cite')
        if !video and elem.length > 0
          video = "http://#{elem.text()}"

        # Send everything
        if video
          msg.send video
        if text
          msg.send text
        msg.send searchUrl
