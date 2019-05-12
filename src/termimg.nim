import nimPNG

proc renderImage*(img: PNGResult, w, h: int): string =
  for y in 0..<int(h / 2):
    for x in 0..<w:
      let
        ix = int x / w * img.width.float
        iy = int (y * 2) / h * img.height.float
        offset1 = (ix + iy * img.width) * 3
        r1 = int img.data[offset1]
        g1 = int img.data[offset1 + 1]
        b1 = int img.data[offset1 + 2]
        offset2 = (ix + (iy + 1) * img.width) * 3
        r2 = int img.data[offset2]
        g2 = int img.data[offset2 + 1]
        b2 = int img.data[offset2 + 2]
      result.add(
        "\e[48;2;" & $r1 & ";" & $g1 & ";" & $b1 & "m" &
        "\e[38;2;" & $r2 & ";" & $g2 & ";" & $b2 & "m▄")
    result.add("\e[0m\n")
  result.add("\e[0m")

when isMainModule:
  import os
  import parseopt
  import strutils

  var
    file = "image.png"
    width = 32
    height = 32

  var opt = initOptParser(commandLineParams())
  for t, k, v in getopt(opt):
    case t
    of cmdShortOption, cmdLongOption:
      case k
      of "w", "width": width = parseInt(v)
      of "h", "height": height = parseInt(v)
      of "i", "input": file = v
      else: discard
    else: discard

  let png = loadPNG24(file)
  stdout.write(renderImage(png, width, height))
