import nimPNG

type
  CoordAlgorithm* = enum
    caNew
    caOld

proc renderImage*(img: PNGResult, w, h: int, algo = caNew): string =
  for y in 0..<int(h / 2):
    for x in 0..<w:
      let
        ix = int x / w * img.width.float
        iy1 = int (y * 2) / h * img.height.float
        iy2 = int(case algo
          of caNew: (y * 2 + 1) / h * img.height.float
          of caOld: iy1.float + 1.0)
        offset1 = (ix + iy1 * img.width) * 3
        offset2 = (ix + iy2 * img.width) * 3
        r1 = int img.data[offset1]
        g1 = int img.data[offset1 + 1]
        b1 = int img.data[offset1 + 2]
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
  import terminal

  type
    ErrorCode = enum
      # fs errors
      eNoFile = (0x00, "no file specified")
      eCouldNotLoadImg = "could not load image '$#'"
      # cmd errors
      eUnknownParam = (0x20, "unknown parameter '$#'")
      eUnknownAlgo = "unknown algorithm '$#'"

  proc err(errCode: ErrorCode, sub: varargs[string, `$`]) =
    styledEcho(fgRed, styleBright, "error: ",
               resetStyle, $errCode % sub)
    quit(errCode.int)

  var
    file = ""
    width = 32
    height = 32
    algo = caNew

  var opt = initOptParser(commandLineParams())
  for t, k, v in getopt(opt):
    case t
    of cmdShortOption, cmdLongOption:
      case k
      of "w", "width": width = parseInt(v)
      of "h", "height": height = parseInt(v)
      of "algo":
        algo =
          case v
          of "new": caNew
          of "old": caOld
          else: err(eUnknownAlgo, v); caNew
      else: err(eUnknownParam, k)
    of cmdArgument:
      file = k
    else: discard

  if file == "": err(eNoFile)

  let png = loadPNG24(file)
  if png.isNil: err(eCouldNotLoadImg, file)

  stdout.write(renderImage(png, width, height, algo))
