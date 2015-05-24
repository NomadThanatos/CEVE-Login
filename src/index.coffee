fs = require "fs"
auth = require "./network.coffee"
execEVE = require "./exec.coffee"
{loadConfig, saveConfig} = require "./data.coffee" 

doc = null
password = null

getData = (callback) ->
  password = prompt "Please input local password.", ""
  key = new Buffer password
  loadConfig "./data.dat", key, (res, err) ->
    if err
      alert "Wrong local password!"
      getData callback;
    else
      doc = res
      callback doc
      

setPassword = (callback) ->
  setword = prompt "Please set local password.", ""
  if setword
    confirmword = prompt "Please re-enter local password.", ""
    if setword != confirmword
      alert "The inputs do not match,please set again!"
      setPassword callback
    else
      password = setword
      if callback
        doc = {};
        doc["path"] = prompt "EVE run path:", "?:\\EVE\\bin\\exefile.exe"
        doc["account"] = [];
        key = new Buffer password
        saveConfig "./data.dat", key, doc
        callback doc
  else
    setPassword callback

render = (doc) ->
  $("#commonSelect").empty()
  $("#uncommonSelect").empty()
  for acc in doc["account"]
    if acc.common
      $("#commonSelect").append("<option value=\"#{acc.username}\">#{acc.username}</option>");
    else
      $("#uncommonSelect").append("<option value=\"#{acc.username}\">#{acc.username}</option>");
      
$(document).ready ->
  if fs.existsSync("./data.dat")
    getData render
  else
    setPassword render

$("#moveLeft").click ->
  list = []
  $("#uncommonSelect :selected").each (i, selected) ->
    list.push $(selected).text();

  for pending in list
    for acc in doc["account"]
      if pending == acc.username
        acc.common = true

  render doc

$("#moveRight").click ->
  list = []
  $("#commonSelect :selected").each (i, selected) ->
    list.push $(selected).text();

  for pending in list
    for acc in doc["account"]
      if pending == acc.username
        acc.common = false

  render doc

$("#addAccount").click ->
  tmp = {};
  tmp["common"] = true;
  tmp["username"] = prompt "Please input username.", ""
  tmp["password"] = prompt "Please input password.", ""
  if tmp["username"] and tmp["password"]
    cardPath = prompt "Please input card path, if none, please enter nothing.", ""
    if cardPath
      file = fs.readFileSync cardPath, "utf-8"
      alert file
      tmp["card"] = {}
      count = 0
      codeArray = [];
      for line in file.split('\r\n')
        codeArray.push.apply codeArray, line.split(" ")
        
      for i in ['1', '2', '3', '4', '5', '6', '7', '8', '9']
        for c in ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I']
          tmp["card"][c + i] = codeArray[count]
          count = count + 1
          
    doc["account"].push tmp
    render doc
  else
    alert "Username or password is null!"

$("#saveLayout").click ->
  key = new Buffer password
  saveConfig "./data.dat", key, doc
  
$("#delAccount").click ->
  list = []
  $("#commonSelect :selected").each (i, selected) ->
    list.push $(selected).text()
  $("#uncommonSelect :selected").each (i, selected) ->
    list.push $(selected).text()
  tmp = [];
  for acc in doc["account"]
    del = false
    for pending in list
      if pending == acc.username
        del = true
    if not del
      tmp.push acc;

  doc["account"] = tmp
  render doc
    
$("#modifyPath").click ->
  doc["path"] = prompt "EVE run path:", doc["path"]
  
$("#modifyPassword").click ->
  setPassword null
    
$("#startCommon").click ->
  for acc in doc["account"]
    if acc.common
      auth acc.username, acc.password, acc.card, (token, err) ->
        alert err if err
        execEVE doc["path"], token
      

$("#startUncommon").click ->
  for acc in doc["account"]
    if not acc.common
      auth acc.username, acc.password, acc.card, (token, err) ->
        alert err if err
        execEVE doc["path"], token
      
$("#startSelected").click ->
  list = [];
  $("#commonSelect :selected").each (i, selected) ->
    list.push $(selected).text()
  $("#uncommonSelect :selected").each (i, selected) ->
    list.push $(selected).text()
  for pending in list
    for acc in doc["account"]
      if pending == acc.username
        auth acc.username, acc.password, acc.card, (token, err) ->
          alert err if err
          execEVE doc["path"], token
