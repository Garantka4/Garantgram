import sys
import os
import zipfile
import plistlib
import tempfile
import shutil

def patch_ipa_bundle_id(src_path, dst_path, old_bid='ph.telegra.Telegraph', new_bid='org.garantka.garantgram'):
    print(f"Patching IPA bundle ID from {old_bid} to {new_bid}...")
    temp_dst = dst_path + ".tmp"
    with zipfile.ZipFile(src_path, 'r') as zin, zipfile.ZipFile(temp_dst, 'w', compression=zipfile.ZIP_DEFLATED) as zout:
        for item in zin.infolist():
            data = zin.read(item.filename)
            if item.filename.endswith('Info.plist'):
                try:
                    plist = plistlib.loads(data)
                    changed = False
                    if 'CFBundleIdentifier' in plist and old_bid in plist['CFBundleIdentifier']:
                        plist['CFBundleIdentifier'] = plist['CFBundleIdentifier'].replace(old_bid, new_bid)
                        changed = True
                    if 'CFBundleURLTypes' in plist:
                        for u in plist['CFBundleURLTypes']:
                            if 'CFBundleURLName' in u and old_bid in u['CFBundleURLName']:
                                u['CFBundleURLName'] = u['CFBundleURLName'].replace(old_bid, new_bid)
                                changed = True
                    if 'BGTaskSchedulerPermittedIdentifiers' in plist:
                        plist['BGTaskSchedulerPermittedIdentifiers'] = [
                            x.replace(old_bid, new_bid) for x in plist['BGTaskSchedulerPermittedIdentifiers']
                        ]
                        changed = True
                    if changed:
                        data = plistlib.dumps(plist)
                        print(f"  Patched: {item.filename}")
                except Exception as e:
                    print(f"  Warning reading {item.filename}: {e}")
            zout.writestr(item, data)
    
    shutil.move(temp_dst, dst_path)
    print(f"Successfully generated patched IPA at {dst_path} (size: {os.path.getsize(dst_path)} bytes)")

if __name__ == '__main__':
    if len(sys.argv) < 3:
        print("Usage: patch_ipa_bundle_id.py <src_ipa> <dst_ipa> [old_bid] [new_bid]")
        sys.exit(1)
    src = sys.argv[1]
    dst = sys.argv[2]
    old_id = sys.argv[3] if len(sys.argv) > 3 else 'ph.telegra.Telegraph'
    new_id = sys.argv[4] if len(sys.argv) > 4 else 'org.garantka.garantgram'
    patch_ipa_bundle_id(src, dst, old_id, new_id)
