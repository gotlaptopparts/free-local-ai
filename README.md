# Free Local AI Setup — Replace $82/month in AI Subscriptions

> One script. 20 minutes. Private AI on your laptop forever. No subscription. No cloud. No account.

**Run on Mac:**
```bash
curl -s https://gotlaptopparts.com/ai-setup/mac.sh | bash
```

**Run on Windows (PowerShell):**
```powershell
irm https://gotlaptopparts.com/ai-setup/windows.ps1 | iex
```

→ **Full guide + download page:** [gotlaptopparts.com/ai-setup](https://www.gotlaptopparts.com/ai-setup)

---

## What this script does

This script installs a complete private AI stack on any Mac or Windows laptop in about 20 minutes. When it finishes, you have:

- **AI chat** — like ChatGPT, but running locally. Nothing leaves your machine.
- **AI in your browser** — ask AI about any webpage you're reading
- **AI for your documents** — drag any PDF or file, ask questions about it
- **System-wide AI (Mac)** — highlight text in any app, press a shortcut, AI responds

Everything runs on your laptop. No internet required after setup. No data sent anywhere. Free forever.

---

## What AI subscriptions this replaces

| Service | Monthly cost | Replaced by |
|---|---|---|
| ChatGPT Plus | $20/month | LM Studio + local model |
| Perplexity Pro | $20/month | Page Assist browser extension |
| GitHub Copilot | $10/month | Continue.dev + Cline in VS Code |
| Claude Pro | $20/month | AnythingLLM + local model |
| Grammarly Premium | $12/month | System-wide AI assistant |
| **Total** | **$82/month** | **$0 forever** |

---

## What gets installed

| Tool | Purpose | Cost |
|---|---|---|
| [Ollama](https://ollama.com) | AI engine — runs all models locally | Free |
| [LM Studio](https://lmstudio.ai) | ChatGPT-style chat interface | Free |
| [Jan.ai](https://jan.ai) | Fully offline, privacy-first chat | Free |
| [AnythingLLM](https://anythingllm.com) | Chat with your documents locally | Free |
| [Page Assist](https://github.com/n4ze3m/page-assist) | AI in Chrome, Firefox, Edge | Free |
| VS Code + Continue + Cline | Local AI coding assistant | Free (developer mode) |

All open source. No accounts. No API keys. No telemetry.

---

## Which AI model gets installed

The script detects your hardware and installs the best model automatically:

| Your RAM | Model installed | What it runs |
|---|---|---|
| 6–11GB | Phi-4 Mini | Fast chat, basic tasks |
| 12–23GB | Llama 3.1 8B | Full quality, all tasks |
| 24–47GB | Qwen3 32B | Near-frontier quality |
| 48GB+ | Llama 3.1 70B | Maximum capability |

You can switch to any of 200+ models inside LM Studio after setup — no technical knowledge needed.

---

## How to run it

### Mac

```bash
# Open Terminal (press Cmd+Space, type "Terminal", press Enter)
curl -s https://gotlaptopparts.com/ai-setup/mac.sh | bash
```

The script will ask:
1. Who is this for? (General use / Developer / Business)
2. What do you want to name your AI? (optional)

Then walk away. It handles everything.

### Windows

```powershell
# Open PowerShell (search "PowerShell", right-click, Run as Administrator)
irm https://gotlaptopparts.com/ai-setup/windows.ps1 | iex
```

Same prompts. Same result.

### Requirements

- Mac: macOS 12+ (Sonoma recommended), 6GB+ RAM, 15GB+ free storage
- Windows: Windows 10/11, 6GB+ RAM, 15GB+ free storage, internet connection

---

## Frequently asked questions

**Is this script safe to run?**
Yes. The code is fully open source — you're reading it right now. It only installs free, widely-used tools (Ollama, LM Studio, Jan.ai, AnythingLLM) via Homebrew (Mac) or winget (Windows). It does not collect data, does not phone home, and does not modify system files outside standard app installation paths.

**Does my data stay private?**
100%. Everything runs on your laptop. Your prompts, documents, and conversations never leave your machine. There are no accounts, no servers, no telemetry.

**Does it work without internet after setup?**
Yes. Once the model is downloaded, AI works completely offline. Works on planes, in remote areas, anywhere.

**What if something goes wrong?**
The script handles errors gracefully. If a download fails it retries automatically. If your storage is too low it cleans up and tries a smaller model. If you get stuck, see [gotlaptopparts.com/ai-setup/help](https://www.gotlaptopparts.com/ai-setup/help) or call (775) 203-1085.

**Can I choose a different AI model?**
Yes. Open LM Studio → click Discover → browse 200+ models → download any with one click. No command line needed.

**Does it work on Apple Silicon (M1/M2/M3/M4)?**
Yes — and it works best on Apple Silicon. Metal GPU acceleration is automatic. A MacBook Pro M2 with 16GB runs Llama 3.1 8B at 30–80 tokens per second.

**What about NVIDIA GPU laptops?**
The script automatically detects your NVIDIA GPU, updates drivers, and configures Ollama to use CUDA. Your GPU VRAM determines which models you can run at full speed.

**Can I uninstall everything?**
Yes. See the [Uninstall Guide](https://www.gotlaptopparts.com/ai-setup/uninstall).

**How do I update to a newer model?**
Open LM Studio → Discover → download the new model. Or run `ollama pull [model-name]` in Terminal.

**Is this affiliated with Ollama, LM Studio, or any AI company?**
No. This script is built and maintained by [GotLaptopParts.com](https://www.gotlaptopparts.com) (Laptop Mate LLC, Reno NV). We sell refurbished laptops and we believe everyone should have access to free, private AI. All tools installed are independent open-source projects.

---

## For developers

Developer mode installs the full coding stack:

```
Ollama → LM Studio → Jan.ai → AnythingLLM → VS Code → Continue.dev → Cline
```

Continue.dev is pre-configured to use your local model via Ollama API at `localhost:11434`. Drop-in replacement for GitHub Copilot. Free. Private. No rate limits.

Cline gives you an agentic coding assistant that can read, write, and execute code across your project.

---

## Want a laptop with this pre-installed?

We sell refurbished laptops with everything pre-configured, model pre-downloaded, and verified running before shipping. Turn it on — AI works immediately.

→ [Shop AI-Ready Laptops](https://www.gotlaptopparts.com/ai-builds)

---

## Contributing

Found a bug? Open an issue. Have a better model recommendation? Submit a PR. Want to add a new tool to the stack? We welcome contributions.

When contributing:
- Test on real hardware before submitting
- Keep hobbyist output simple — no technical jargon shown to general users
- Maintain the fallback chain — the script must always find a working config
- Do not add anything that phones home or collects data

---

## Security

This script is open source so you can audit every line. Key facts:

- Installs only via Homebrew and winget (verified package managers with signed packages)
- Downloads models only from Ollama's official servers
- Never connects to GotLaptopParts servers during execution
- Never collects personal data
- Never modifies files outside standard app installation paths

To verify the script before running:
```bash
# Mac — download and read before running
curl -s https://gotlaptopparts.com/ai-setup/mac.sh > setup.sh
cat setup.sh  # read it
bash setup.sh  # then run it
```

---

## License

MIT License — free to use, modify, and distribute. Attribution appreciated.

---

## Built by

[GotLaptopParts.com](https://www.gotlaptopparts.com) · Laptop Mate LLC · Reno, NV

We sell refurbished laptop parts and complete devices. We built this script because we believe everyone deserves private, free AI — regardless of whether they buy from us.

- Website: [gotlaptopparts.com](https://www.gotlaptopparts.com)
- AI Setup Page: [gotlaptopparts.com/ai-setup](https://www.gotlaptopparts.com/ai-setup)
- AI-Ready Laptops: [gotlaptopparts.com/ai-builds](https://www.gotlaptopparts.com/ai-builds)
- Used Laptops: [onlineusedlaptops.com](https://www.onlineusedlaptops.com)
- Phone: (775) 203-1085
