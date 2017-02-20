import os
import osproc
import strutils
import random

# Seed the random number generator
randomize()


proc findOrCreateTempDir(srcFile: string): string =
  ## Checks for existing temporary directories so that we might use
  ## the already cached compilation results.  If no directory exists,
  ## we create one
  let tmpDir = getTempDir()
  let (_, srcName, _) = splitFile(srcFile)

  result = tmpDir / "nimr" / srcName

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
  let outputs = "--out:$1_executable --nimcache:$1 ".format(tmpdir)

  let (srcPath, _) = splitPath(srcFile)

  result = execCmd(compCmd & outputs & srcFile)


when isMainModule:

  let compiler = selectCompiler()
  var args = commandLineParams()

  if args.len == 0:
    quit(0)

  let srcFile = args[0]
  args.delete(0)

  let tmpDir = findOrCreateTempDir(srcFile)
  defer:
    removeDir(tmpDir)

  let compilerResult = compile(compiler, tmpDir, srcFile)

  if compilerResult == 0:
    quit(execCmd("$1_executable ".format(tmpDir) & args.join(" ")))
  else:
    quit(compilerResult)
