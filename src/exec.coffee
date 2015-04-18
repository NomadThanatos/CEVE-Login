process = require "child_process"


execEVE = (evePath, token) ->
  process.exec evePath + " /noconsole /ssoToken=#{token} /triPlatform=dx11", () ->

module.exports = execEVE
