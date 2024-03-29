import asyncdispatch
import asyncnet
import tables
import terminal

import client
import commands
import config

proc processClient(user: User) {.async.} =
  await user.client.send("\e[32m" & channelMotd & "\e[0m\n\n")
  await user.client.send(
    "\e[95mWelcome to channel \e[97m" & channelName & "\e[95m!\e[0m")
  var nickname = ""
  while nickname in ["", "\c\n", "\n"]:
    await user.client.send(
      "\n\e[96mEnter your nickname:\e[97m ")
    nickname = await user.client.recvLine()
  user.nick = nickname
  users.add(user)
  await sendToAll("\e[97m" & user.nick & "\e[92m joined the channel")
  while true:
    let msg = await user.client.recvLine()
    if msg == "":
      for i in countdown(users.len - 1, 0):
        if users[i] == user:
          users.delete(i)
          break
      await sendToAll("\e[97m" & user.nick & "\e[91m quit the channel")
      styledEcho(fgWhite, user.client.getLocalAddr()[0], fgRed, " disconnected")
      return
    else:
      try:
        if msg[0] == CmdPrefix and msg.len > 1:
          let cmd = parseCommand(msg)
          if cmds.hasKey((cmd[0], cmd.len - 1)):
            await cmds[(cmd[0], cmd.len - 1)](user, cmd)
          else:
            await user.send(
              "\e[31mCommand \e[97m" & cmd[0] & "(" & $(cmd.len - 1) &
              ")\e[31m doesn't exist - Type /help for help.")
        elif msg in ["\c\n", "\n"]:
          await user.client.send("\r\e[1T" & Prompt)
        else:
          await user.send("\r\e[2A")
          await sendToAll("\e[97m" & user.nick & ":\e[0m " & msg)
      except:
        await user.send(
          "\e[31mAn internal error occured while processing your request")
        echo getCurrentExceptionMsg()

proc serve*() {.async.} =
  styledEcho(fgGreen, "shitchat server by iLiquid")
  echo "starting server..."
  users = @[]
  var server = newAsyncSocket()
  server.setSockOpt(OptReuseAddr, true)
  server.bindAddr(Port(port))
  server.listen()

  styledEcho(fgWhite, "Use `nc <your ip> ", $port, "` to connect")

  addQuitProc do:
    for usr in users:
      usr.client.close()

  try:
    while true:
      let
        client = await server.accept()
        user = User(client: client, nick: "anon")

      styledEcho(fgWhite, client.getPeerAddr()[0], fgGreen, " connected")

      asyncCheck processClient(user)
  except Exception as e:
    styledEcho(fgRed, "An exception has been caught!")
    styledEcho(fgWhite, styleDim, "Message: ", resetStyle, e.msg)
    styledEcho(fgWhite, styleDim, "Stack traceback:")
    writeStackTrace()
