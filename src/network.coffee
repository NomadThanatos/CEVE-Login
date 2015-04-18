fs = require("fs")
request = require("request")
querystring = require("querystring")
jsdom = require("jsdom")

jquery = fs.readFileSync("../lib/jquery.js", "utf-8")

hostname = "https://auth.eve-online.com.cn";
path = "/Account/LogOn?ReturnUrl=%2foauth%2fauthorize%3fclient_id%3deveclient%26scope%3deveClientLogin%26response_type%3dtoken%26redirect_uri%3dhttps%253A%252F%252Fauth.eve-online.com.cn%252Flauncher%253Fclient_id%253Deveclient%26lang%3dzh&client_id=eveclient&scope=eveClientLogin&response_type=token&redirect_uri=https%3A%2F%2Fauth.eve-online.com.cn%2Flauncher%3Fclient_id%3Deveclient&lang=zh"

auth = (username, password, card, cb) ->
  form = {
    UserName: username,
    Password: password
  }

  req = request.defaults({jar: true})

  req.post {url: hostname + path, form}, (err, res, body) ->

    cb null, err if err

    jsdom.env body, src: [jquery], (err, res) ->

      cb null, err if err
      
      if res.$(".validation-summary-errors").size() != 0
        cb null, res.$(".validation-summary-errors").text()

      #two step auth
      if res.$(".block").size() != 0
        authCode = res.$(".block").text().match(/\S+/g)
        href = res.$("form").attr("action")
        form = {
          MatrixCardOne: card[authCode[0]],
          MatrixCardTwo: card[authCode[1]],
          MatrixCardThree: card[authCode[2]]
        }
        
        req.post {url: hostname + href, form}, (err, res, body) ->

          cb null, err if err

          jsdom.env body, src: [jquery], (err, res) ->
            
            cb null, err if err

            if res.$(".validation-summary-errors").size() != 0
              cb null, res.$(".validation-summary-errors").text()

            jsdom.env body, src: [jquery], (err, res) ->

              cb null, err if err
              
              href = res.$("a").attr("href");
              req.get {url: hostname + href}, (err, res, body) ->

                cb null, err if err

                cb querystring.parse(res.request.uri.hash)["#access_token"], null
      else
        href = res.$("a").attr("href");
        req.get {url: hostname + href}, (err, res, body) ->
            
          cb null, err if err
            
          cb querystring.parse(res.request.uri.hash)["#access_token"], null

module.exports = auth
