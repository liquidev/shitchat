import asyncdispatch
import asyncnet

import nimPNG

import staticconf

type
  User* = ref object
    client*: AsyncSocket
    nick*: string

var users*: seq[User]

proc send*(user: User, message: string) {.async.} =
  await user.client.send("\r\e[2K" & message & "\n" & Prompt)

proc sendToAll*(message: string) {.async.} =
  for user in users:
    await user.send(message)
