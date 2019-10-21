import os
import parsecfg
import streams
import strutils
import terminal

const
  DefaultConfig* = slurp("default_config.cfg")
  ShortHelp* = """
shitchat: shitty netcat chat
copyright (C) iLiquid, 2019

COMMANDS
  /help                                     show this
  /man                                      detailed manual
  /clear                                    clear your screen
  /nick <new nickname>                      change your nickname
  /image <width> <height> <url>             send an image

FORMATTING (not implemented yet)
  *italic*
  **bold**
  ***bold italic***
  !(image url)
  .color`foreground color` ,color`background color`
    See manual for available colors

Type /man for a detailed manual.
"""
  Manual* = """
shitchat(1)                         shitchat                         shitchat(1)

NAME
  shitchat: shitty netcat chat.

USAGE
  To run a shitchat server, use:
    $ shitchat <channel name>

  To connect to a shitchat server, use:
    $ nc <host IP> 12321

COMMANDS
  /help                                   short help
  /man                                    show this
  /clear                                  clear your screen
  /nick <new nickname>                    change your nickname
  /image <width> <height> <url>           send an image
"""
  Prompt* = "\e[91m ·\e[93m · \e[92m· \e[0m"
  CmdPrefix* = '/'

var
  port*: int
  channelName*, channelMotd*: string

type
  ConfigError* = object of CatchableError

proc loadConfig*(file: string) =
  if not fileExists(file):
    styledEcho(fgYellow, "Config file ", fgWhite, file,
               fgYellow, " doesn't exist. Creating with default settings")
    writeFile(file, DefaultConfig)
  var
    istream = openFileStream(file, fmRead)
    cfg: CfgParser
    errored = false
  cfg.open(istream, file)

  proc printErr(msg: string) =
    styledEcho(fgRed, "Error: ", fgWhite, cfg.errorStr(msg))
    errored = true

  var section = ""
  while true:
    let ev = cfg.next()
    case ev.kind
    of cfgEof: break
    of cfgError:
      printErr(ev.msg)
    of cfgSectionStart:
      section = ev.section
      if section notin ["Connection", "Channel"]:
        printErr("invalid section: " & section)
    of cfgKeyValuePair:
      case section
      of "Connection":
        case ev.key
        of "port":
          try: port = parseInt(ev.value)
          except ValueError: printErr("invalid integer: " & ev.value)
          if port notin 1..65536:
            printErr("port out of range 1..65536")
        else: printErr("invalid setting: " & ev.key)
      of "Channel":
        case ev.key
        of "name": channelName = ev.value
        of "motd": channelMotd = ev.value.strip(chars = Newlines)
        else: printErr("invalid setting: " & ev.key)
    of cfgOption: printErr("no options are available")
  if errored:
    raise newException(ConfigError,
                       "errors occured in config file, check log for details")
