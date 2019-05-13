import asyncdispatch
import os
import parseopt
import tables
import terminal

import nimPNG

import server

var opt = initOptParser(commandLineParams())
for t, k, v in getopt(opt):
  case t
  of cmdArgument:
    channelName = k
  else: discard

if channelName == "":
  styledEcho(fgRed, "Usage: ", resetStyle, "shitchat <channel-name>")
  quit(QuitFailure)

asyncCheck serve()
runForever()
