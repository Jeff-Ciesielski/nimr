import os
import osproc
import strutils
import random

# Seed the random number generator
randomize()


proc randomString(length: int): string =
  result = newString(length)
  for i in 0..<length:
    result[i] =  random('A'.int..'Z'.int).char


proc createSrcTempDir(srcFile: string): string =
  let tmpDir = getTempDir()
  let (_, srcName, _) = splitFile(srcFile)
  let suffix = randomString(4)

  result = tmpDir / srcName / "." / suffix

  createDir(result)


proc selectCompiler(): string =
  if findExe("tcc") != "":
    result = "tcc"
  elif findExe("clang") != "":
    result = "clang"
  else:
    result = "gcc"


proc compile(compiler, tmpdir, srcFile: string): int =
  let compCmd = "nim c --verbosity:0 --hints:off --cc:$1 ".format(compiler)
  let outputs = "--out:$1executable --nimcache:$1 ".format(tmpdir)

  let (srcPath, _) = splitPath(srcFile)

  result = execCmd(compCmd & outputs & srcFile)


when isMainModule:

  let compiler = selectCompiler()
  var args = commandLineParams()

  if args.len == 0:
    quit(0)

  let srcFile = args[0]
  args.delete(0)

  let tmpDir = createSrcTempDir(srcFile)
  defer:
    removeDir(tmpDir)

  let compilerResult = compile(compiler, tmpDir, srcFile)

  if compilerResult == 0:
    quit(execCmd("$1executable ".format(tmpDir) & args.join(" ")))
  else:
    quit(compilerResult)
