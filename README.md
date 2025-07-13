# 🕵️ Bug Bounty Recon Pipeline - `zegs.sh`

An advanced and fully automated bash script for bug bounty reconnaissance. It chains together powerful tools for subdomain discovery, URL collection, JS secret detection, CORS misconfigurations, SQL injection, subdomain takeover, HTTP request smuggling, and directory brute-forcing — all with live Discord notifications.

## ✨ Features

- Subdomain enumeration with `subfinder`, `assetfinder`, `Sublist3r`
- Live host detection with `httpx`
- Subdomain takeover detection via `subzy`
- CORS misconfiguration detection via `Corsy`
- URL discovery with `katana`, `gau`, and `waymore`
- JS leak scanning with `mantra`
- Parameter discovery and SQL injection with `SQLMap`
- Directory brute-forcing with `Dirsearch`
- HTTP request smuggling with `Smuggler`
- Real-time reporting to Discord using `notify`

## 🛠 Requirements

- Linux / WSL / VPS (Ubuntu preferred)
- Go (≥1.22), Python 3
- Tools installed globally:
  - [`subfinder`](https://github.com/projectdiscovery/subfinder)
  - [`assetfinder`](https://github.com/tomnomnom/assetfinder)
  - [`httpx`](https://github.com/projectdiscovery/httpx)
  - [`katana`](https://github.com/projectdiscovery/katana)
  - [`gau`](https://github.com/lc/gau)
  - [`waymore`](https://github.com/xnl-h4ck3r/waymore)
  - [`subzy`](https://github.com/LukaSikic/subzy)
  - [`mantra`](https://github.com/Brosck/mantra)
  - [`notify`](https://github.com/projectdiscovery/notify)
  - [`arjun`](https://github.com/s0md3v/Arjun)
  - [`dirsearch`](https://github.com/maurosoria/dirsearch)
  - [`sqlmap`](https://github.com/sqlmapproject/sqlmap)
  - [`corsy`](https://github.com/s0md3v/Corsy)
  - [`smuggler`](https://github.com/defparam/smuggler)
  - [`Sublist3r`](https://github.com/aboul3la/Sublist3r)

## ⚙️ Setup

```bash
sudo apt update && sudo apt install -y python3-pip git curl
# Install Go and set GOPATH
wget https://golang.org/dl/go1.22.4.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.22.4.linux-amd64.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> ~/.bashrc
source ~/.bashrc

# Install Go tools
go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
go install github.com/projectdiscovery/httpx/cmd/httpx@latest
go install github.com/projectdiscovery/katana/cmd/katana@latest
go install github.com/projectdiscovery/notify/cmd/notify@latest
go install github.com/lc/gau@latest
go install github.com/LukaSikic/subzy@latest
go install github.com/Brosck/mantra@latest

# Clone Python tools
git clone https://github.com/s0md3v/Corsy /tools/Corsy
git clone https://github.com/aboul3la/Sublist3r /tools/Sublist3r
git clone https://github.com/defparam/smuggler /tools/smuggler
git clone https://github.com/xnl-h4ck3r/waymore /tools/waymore
git clone https://github.com/s0md3v/Arjun /tools/Arjun
cd /tools/Arjun && pip install .

# Move binaries
sudo mv ~/go/bin/* /usr/local/bin/
sudo ln -s /tools/Corsy/corsy.py /usr/local/bin/corsy
sudo ln -s /tools/dirsearch/dirsearch.py /usr/local/bin/dirsearch
sudo ln -s /tools/Arjun/sqlmap/sqlmap.py /usr/local/bin/sqlmap


## 🚀 Requirements

- Go ≥ 1.23
- Python 3
- Tools in `/usr/local/bin`:
  - subfinder, assetfinder, httpx, subzy, notify
  - katana, gau, waymore
  - corsy, sqlmap, dirsearch, mantra
- Notify config (`~/.config/notify/provider-config.yaml`)

## ✅ Usage

```bash
chmod +x zegs.sh
./zegs.sh target.com
```

Results saved in `output/target-timestamp/`.

## 📁 Output Structure

```
output/
└── example.com-2025-07-13_16-45-30/
    ├── subs.txt
    ├── live.txt
    ├── urls.txt
    ├── js_urls.txt
    ├── php_urls.txt
    ├── mantra/
    │   └── mantra_output.json
    ├── sqlmap/
    │   └── sqlmap_scan.log
    ├── dirsearch/
    │   └── dirsearch_results.txt
    └── smuggler/
        └── smuggler_report.txt
```



## 🤝 Contributing

Contributions are welcome! If you have suggestions for improvements, bug fixes, or new features, feel free to open an issue or submit a pull request. Let's build better recon together!
