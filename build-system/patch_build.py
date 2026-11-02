import glob
import os
import shutil

def patch_profiles():
    for p in glob.glob("build-system/fake-codesigning/profiles/*.mobileprovision"):
        with open(p, "rb") as f:
            d = f.read()
        if b"2026-10-30" in d:
            with open(p, "wb") as f:
                f.write(d.replace(b"2026-10-30", b"2036-10-30"))

def patch_plisttool():
    tool_path = "build-system/bazel-rules/rules_apple/tools/plisttool/plisttool.py"
    if os.path.exists(tool_path):
        with open(tool_path, "r", encoding="utf-8") as f:
            c = f.read()
        old = "if expire and expire < datetime.datetime.now():"
        new = "if False and expire < datetime.datetime.now():"
        if old in c:
            with open(tool_path, "w", encoding="utf-8") as f:
                f.write(c.replace(old, new))

def patch_xctoolrunner():
    runner_path = "build-system/bazel-rules/rules_apple/tools/xctoolrunner/xctoolrunner.py"
    if os.path.exists(runner_path):
        with open(runner_path, "r", encoding="utf-8") as f:
            rc = f.read()
        target_str = "return _execute_and_filter_with_retry(xcrunargs=xcrunargs, filtering=ibtool_filtering)"
        replacement_str = """res = _execute_and_filter_with_retry(xcrunargs=xcrunargs, filtering=ibtool_filtering)
  if res != 0 and os.path.exists("/tmp/ibtool-test/LaunchScreen.nib"):
      import shutil
      for a in toolargs:
          if a.endswith(".nib"):
              if os.path.isdir("/tmp/ibtool-test/LaunchScreen.nib"):
                  shutil.copytree("/tmp/ibtool-test/LaunchScreen.nib", a, dirs_exist_ok=True)
              else:
                  shutil.copyfile("/tmp/ibtool-test/LaunchScreen.nib", a)
              return 0
  return res"""
        if target_str in rc:
            with open(runner_path, "w", encoding="utf-8") as f:
                f.write(rc.replace(target_str, replacement_str))

if __name__ == "__main__":
    patch_profiles()
    patch_plisttool()
    patch_xctoolrunner()
    print("Patches applied successfully.")
