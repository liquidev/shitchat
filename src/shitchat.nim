import asyncdispatch
import os
import parseopt

import config
import server

var
  configFile = "shitchat.cfg"

var opt = initOptParser(commandLineParams())
for t, k, v in getopt(opt):
  case t
  of cmdShortOption:
    case k
    of "c": configFile = v
  else: discard

loadConfig(configFile)

asyncCheck serve()
runForever()
