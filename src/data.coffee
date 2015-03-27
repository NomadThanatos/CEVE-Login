fs = require("fs");
yaml = require("js-yaml");
{encrypt, decrypt} = require("triplesec");

module.exports.loadConfig = loadConfig(fileLocation, key) ->
  decrypt { key, data : fs.readFileSync(fileLocation) }, (err, raw) ->
    #if (err) throw err;
    doc = yaml.safeload(data);

#module.exports.saveConfig = saveConfig(fileLocation, key, doc) ->
#  raw = yaml.safedump(doc);
#  encrypt { key, data: raw }, (err, ciphertext) ->
#    #if (err) throw err;
#    fs.writeFileSync(fileLocation, raw, err) ->
#      if (err) throw err;
