import os
import osproc
import strutils


proc findOrCreateTempDir(srcFile: string): string =
  ## Checks for existing temporary directories so that we might use
  ## the already cached compilation results.  If no directory exists,
  ## we create one
  let tmpDir = getTempDir()
  let (_, srcName, _) = splitFile(srcFile)

  result = tmpDir / "nimr" / srcName

  createDir(result)


proc selectCompiler(): string =
  ## Try to use tcc/clang first since they tend to be faster, default
  ## to GCC if we can't find either of the others in our path
  if findExe("tcc") != "":
    result = "tcc"
  elif findExe("clang") != "":
    result = "clang"
  else:
    result = "gcc"


proc compile(compiler, tmpdir, srcFile: string): int =
  ## Executes the nim compiler, placing the nimcache and executables
  ## in <tmp>/nimr/
  let
    compCmd = "nim c --threads:on --verbosity:0 --hints:off --cc:$1 ".format(compiler)
    opts = if compiler == "tcc":
             "--tlsEmulation:on "
           else:
             ""
    outputs = "--out:$1_executable --nimcache:$1 ".format(tmpdir)

  result = execCmd(compCmd & opts & outputs & srcFile)


proc main() =
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

when isMainModule:
  main()
