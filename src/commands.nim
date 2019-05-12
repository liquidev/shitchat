import asyncdispatch
import asyncnet
import httpclient
import strutils
import tables

import nimPNG

import client
import staticconf
import termimg

type
  CommandSignature* = tuple
    name: string
    arity: int
  Command* = proc (user: User, args: seq[string]): Future[void]

var cmds* = initTable[CommandSignature, Command]()

proc addCommand*(name: string, arity: int, impl: Command) =
  cmds[(name, arity)] = impl

proc parseCommand*(command: string): seq[string] =
  result = @[]
  var
    arg = ""
    pos = 1 # skip the command prefix
    strMode = false
  while pos < command.len:
    if command[pos] == '"':
      strMode = not strMode
      inc(pos)
      continue
    if not strMode and command[pos] == ' ':
      result.add(arg)
      arg = ""
      inc(pos)
      continue
    arg.add(command[pos])
    inc(pos)
  result.add(arg)

template cmd(name, arity, body) {.dirty.} =
  addCommand(name, arity) do (user: User, args: seq[string]) {.async.}:
    body

cmd("help", 0):
  await user.send(ShortHelp)

cmd("man", 0):
  await user.send(Manual)

cmd("clear", 0):
  await user.send("\e[2J\e[3J\e[1;1H")

cmd("nick", 1):
  let oldNick = user.nick
  user.nick = args[1]
  await sendToAll(
    "\e[97m" & oldNick & "\e[93m set their nickname to \e[97m" & user.nick)

cmd("image", 3):
  try:
    let
      width = parseInt(args[1])
      height = parseInt(args[2])
    await user.client.send("\e[36mDownloading image...\n")
    var http = newAsyncHttpClient()
    let
      pngData = await http.getContent(args[3])
      png = decodePNG24(pngData)
    if png.isNil:
      await user.send(
        "\e[31mCouldn't decode PNG file. Are you sure this is a PNG?")
      return
    await sendToAll("\e[97m" & user.nick & ":\e[0m")
    await renderImage(png, width, height).sendToAll()
  except ValueError:
    await user.send("\e[31mInvalid integer")
  except HttpRequestError:
    await user.send(
      "\e[31mCouldn't read webpage: \e[97m" & getCurrentExceptionMsg())
