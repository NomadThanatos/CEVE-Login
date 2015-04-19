fs = require("fs");
yaml = require("js-yaml");
{encrypt, decrypt} = require("triplesec");

loadConfig = (fileLocation, key, cb) ->
  fileString = fs.readFileSync(fileLocation)
  data = new Buffer fileString
  decrypt { key, data }, (err, raw) ->
    cb null, err if err
    doc = yaml.safeLoad(raw.toString("utf8"));
    cb doc, null;

saveConfig = (fileLocation, key, doc) ->
  raw = new Buffer yaml.safeDump(doc);
  encrypt { key, data: raw }, (err, ciphertext) ->
    throw err if err
    fs.writeFileSync(fileLocation, ciphertext)

module.exports = {loadConfig, saveConfig}
