const
  Welcome* = """
Welcome to shitnode. To protect the network all new connections will be scanned
for vulnerabilities. This will not harm your computer, and vulnerable hosts
will be notified."""
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

        shitchat <channel name>

    To connect to a shitchat server, use:

        nc <host IP> 12321

COMMANDS

    /help                                   short help
    /man                                    show this
    /clear                                  clear your screen
    /nick <new nickname>                    change your nickname
    /image <width> <height> <url>           send an image
"""
  Prompt* = "\e[91m ·\e[93m · \e[92m· \e[0m"
  CmdPrefix* = '/'
