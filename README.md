# shitchat

shitty netcat chat

## Usage

To start a server, run:
```
$ shitchat <channel name>
```
To connect, run:
```sh
$ nc <your IP or localhost> 12321
```
You might need to open the port in your router for others to be able to connect.

For extra help, use the `/help` command in your shitchat session.

## Compiling

To compile shitchat, use:
```sh
$ nim c -d:release src/shitchat
```
(TODO: replace this with `nimble install`)

To compile the termimg tool bundled in this repo, use:
```
$ nim c -d:release src/termimg
```

## termimg

This is an extra tool bundled in this repo, which allows you to display PNGs in
your terminal. Usage:
```sh
$ termimg -i:image.png # the input image \
          -w:64        # the width in terminal columns \
          -h:64        # the height in terminal row halves
```
