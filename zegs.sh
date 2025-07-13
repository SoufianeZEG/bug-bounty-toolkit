#!/bin/bash
set -e

# === Config ===
target=$1
ts=$(date +"%Y-%m-%d_%H-%M-%S")
out="./output/$target-$ts"
mkdir -p "$out"

notify() {
  ( sleep 1 && echo "$2" | /usr/local/bin/notify -silent -provider discord -id "crawl" ) &
}

echo "[*] Recon started for $target"
notify "recon" "[*] Recon started for $target"

# === Subdomain Enumeration ===
echo "[*] Enumerating subdomains"
subfinder -d "$target" -silent >> "$out/subs.txt" || true
assetfinder --subs-only "$target" >> "$out/subs.txt" || true
python3 -W ignore /tools/Sublist3r/sublist3r.py -d "$target" -o "$out/sublister.txt" 2>/dev/null || true
[ -f "$out/sublister.txt" ] && cat "$out/sublister.txt" >> "$out/subs.txt"
sort -u "$out/subs.txt" -o "$out/subs.txt"
notify "subdomains" "🌝 Subdomain enumeration completed for $target"

# === Live Hosts ===
echo "[*] Probing for live hosts"
httpx -silent -list "$out/subs.txt" -o "$out/live.txt" || true
notify "live" "🌍 Live hosts identified"

# === Subdomain Takeover & CORS ===
echo "[*] Checking for subdomain takeover"
subzy run --targets "$out/subs.txt" --hide_fails --output "$out/subzy.txt" || true
notify "subzy" "🏴 Subzy completed"

echo "[*] Checking for CORS issues"
[ -s "$out/live.txt" ] && corsy -i "$out/live.txt" -o "$out/corsy.txt" || echo "[!] No live hosts for CORS check"
notify "corsy" "🦮 Corsy completed"

# === URL Gathering ===
echo "[*] Gathering URLs"
katana -list "$out/live.txt" -o "$out/katana.txt" || true
gau "$target" > "$out/gau.txt" || true
waymore -i "$out/subs.txt" -mode U -oU "$out/waymore.txt" || true

cat "$out/katana.txt" "$out/gau.txt" "$out/waymore.txt" | sort -u > "$out/urls.txt"
notify "urls" "🔗 URLs collected"

# === JS & PHP Extraction ===
echo "[*] Extracting JS and PHP URLs"
grep -iE '\.js(\?|$)' "$out/urls.txt" > "$out/js_urls.txt" || true
grep -iE '\.php(\?|$)' "$out/urls.txt" > "$out/php_urls.txt" || true

# === JS Secrets - Mantra ===
echo "[*] Scanning JS files for secrets"
mkdir -p "$out/mantra"
[ -s "$out/js_urls.txt" ] && cat "$out/js_urls.txt" | /tools/mantra-main/build/mantra-amd64-linux -ua "Mozilla" -t 20 -s -d -ep "apikey|secret|token|pass" > "$out/mantra/secrets.txt" || echo "[!] No JS files to scan"
notify "js" "🔍 JS Secret Analysis complete"

# === SQLMap on PHP URLs ===
echo "[*] Running SQLMap on .php URLs"
mkdir -p "$out/sqlmap"
if [ -f "$out/sqlmap/results.txt" ] && grep -q "resume" "$out/sqlmap/results.txt"; then
  echo "[*] Resuming SQLMap"
  sqlmap --resume || true
else
  while read -r url; do
    sqlmap -u "$url" --batch --level=2 --risk=2 >> "$out/sqlmap/results.txt" || true
  done < "$out/php_urls.txt"
fi
notify "sqlmap" "🧨 SQLMap scan complete"

# === Dirsearch ===
echo "[*] Running Dirsearch"
mkdir -p "$out/dirsearch"
while read -r url; do
  safe_name=$(echo "$url" | sed 's|https\?://||;s|/|_|g')
  dirsearch -u "$url" -w /wordlists/SecLists/Discovery/Web-Content/directory-list-2.3-big.txt -o "$out/dirsearch/$safe_name.txt"
done < "$out/live.txt"
notify -p "dirsearch" "📁 Dirsearch complete"

# === Smuggler ===
echo "[*] Testing HTTP Request Smuggling"
mkdir -p "$out/smuggler"
while read -r host; do
  python3 /tools/smuggler/smuggler.py -u "$host" >> "$out/smuggler/results.txt" || true
done < "$out/live.txt"
notify "smuggler" "📦 Smuggler scan done"

# === Final Summary ===
notify "done" "🎯 Recon complete for $target\n📁 Results in: $out"
echo "[✔] All modules finished."
