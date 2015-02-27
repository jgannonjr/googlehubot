# Description:
#   Example scripts for you to examine and try out.
#
# Notes:
#   They are commented out by default, because most of them are pretty silly and
#   wouldn't be useful and amusing enough for day to day huboting.
#   Uncomment the ones you want to try and experiment with.
#
#   These are from the scripting documentation: https://github.com/github/hubot/blob/master/docs/scripting.md

module.exports = (robot) ->

  robot.respond /(.*)/i, (msg) ->
    query = msg.match[1].split(' ').join('+')
    msg.http("https://www.google.com/search?q=#{query}")
      .get() (err, res, body) ->
        cheerio = require('cheerio')
        $ = cheerio.load(body)
        msg.send $('ol').html() 
