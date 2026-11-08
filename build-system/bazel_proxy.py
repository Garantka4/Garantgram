import http.server
import os
import shutil
import socketserver
import subprocess
import sys
import threading
import urllib.request

CACHE_DIR = "/tmp/bazel_gh_proxy_cache"
os.makedirs(CACHE_DIR, exist_ok=True)
GH_TOKEN = os.environ.get("GH_TOKEN") or os.environ.get("GITHUB_TOKEN")

class ProxyHandler(http.server.BaseHTTPRequestHandler):
    def log_message(self, format, *args):
        sys.stderr.write(f"[BazelProxy] {format % args}\n")
        sys.stderr.flush()

    def _get_file(self):
        if not self.path.startswith("/proxy/"):
            return None
        rel_path = self.path[len("/proxy/"):]
        parts = rel_path.split("/")
        if len(parts) >= 6 and parts[2] == "releases" and parts[3] == "download":
            owner = parts[0]
            repo = parts[1]
            tag = parts[4]
            filename = parts[5].split("?")[0]
            cache_file = os.path.join(CACHE_DIR, f"{owner}_{repo}_{tag}_{filename}")
            if not os.path.isfile(cache_file) or os.path.getsize(cache_file) == 0:
                sys.stderr.write(f"[BazelProxy] Fetching {owner}/{repo} {tag} {filename} via gh...\n")
                sys.stderr.flush()
                dl_dir = os.path.join(CACHE_DIR, f"{owner}_{repo}_{tag}")
                os.makedirs(dl_dir, exist_ok=True)
                res = subprocess.run([
                    "gh", "release", "download", tag,
                    "--repo", f"{owner}/{repo}",
                    "--pattern", filename,
                    "--dir", dl_dir,
                    "--clobber"
                ], capture_output=True)
                downloaded = os.path.join(dl_dir, filename)
                if os.path.isfile(downloaded) and os.path.getsize(downloaded) > 0:
                    shutil.move(downloaded, cache_file)
                else:
                    sys.stderr.write(f"[BazelProxy] gh failed ({res.stderr.decode('utf-8', errors='ignore')}), trying urllib with auth...\n")
                    sys.stderr.flush()
                    orig_url = f"https://github.com/{rel_path}"
                    req = urllib.request.Request(orig_url)
                    if GH_TOKEN:
                        req.add_header("Authorization", f"Bearer {GH_TOKEN}")
                    req.add_header("User-Agent", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)")
                    with urllib.request.urlopen(req, timeout=120) as resp, open(cache_file, "wb") as fp:
                        shutil.copyfileobj(resp, fp)
            if os.path.isfile(cache_file) and os.path.getsize(cache_file) > 0:
                return cache_file
        return None

    def do_HEAD(self):
        f = self._get_file()
        if f:
            self.send_response(200)
            self.send_header("Content-Type", "application/octet-stream")
            self.send_header("Content-Length", str(os.path.getsize(f)))
            self.end_headers()
        else:
            self.send_response(404)
            self.end_headers()

    def do_GET(self):
        f = self._get_file()
        if f:
            self.send_response(200)
            self.send_header("Content-Type", "application/octet-stream")
            self.send_header("Content-Length", str(os.path.getsize(f)))
            self.end_headers()
            with open(f, "rb") as fp:
                shutil.copyfileobj(fp, self.wfile)
        else:
            self.send_response(404)
            self.end_headers()

class ReusableServer(socketserver.ThreadingTCPServer):
    allow_reuse_address = True

def main():
    port = 8088
    server = ReusableServer(("127.0.0.1", port), ProxyHandler)
    sys.stderr.write(f"[BazelProxy] Listening on 127.0.0.1:{port}\n")
    sys.stderr.flush()
    server.serve_forever()

if __name__ == "__main__":
    main()
