# Free Local AI Setup — Private AI on Your Laptop. No Subscription.

> One script. 20 minutes. AI running locally on your laptop forever. No cloud. No account. No monthly fee.

**Run on Mac:**
```bash
curl -s https://gotlaptopparts.com/ai-setup/mac.sh -o /tmp/ai-setup-mac.sh && bash /tmp/ai-setup-mac.sh
```

**Run on Windows (PowerShell):**
```powershell
irm https://gotlaptopparts.com/ai-setup/windows.ps1 -OutFile "$env:TEMP\ai-setup.ps1"; powershell -ExecutionPolicy Bypass -File "$env:TEMP\ai-setup.ps1"
```

→ **Full guide + download page:** [gotlaptopparts.com/ai-setup](https://www.gotlaptopparts.com/ai-setup)

---

## What this script does

Installs a complete private AI stack on any Mac or Windows laptop in about 20 minutes. When it finishes you have:

- **AI chat** — like ChatGPT, running locally. Nothing leaves your machine.
- **AI in your browser** — ask AI about any webpage you're reading
- **AI for your documents** — drag any PDF or file, ask questions about it
- **System-wide AI (Mac)** — highlight text in any app, press a shortcut, AI responds

Everything runs on your laptop. No internet required after setup. No data sent anywhere. Free forever.

---

## What AI subscriptions this can replace

Add up what you currently pay for AI tools. Whatever that number is — this replaces it with $0.

| Service | Listed price | Replaced by |
|---|---|---|
| ChatGPT Plus | $20/month | LM Studio + local model |
| Perplexity Pro | $20/month | Page Assist browser extension |
| GitHub Copilot | $10/month | Continue.dev + Cline in VS Code |
| Claude Pro | $20/month | AnythingLLM + local model |
| Grammarly Premium | $12/month | System-wide AI assistant |

Prices are each company's listed rates — your actual cost may differ. The point: local AI replaces all of these with $0/month.

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
# Open Terminal (Cmd+Space → type Terminal → Enter)
curl -s https://gotlaptopparts.com/ai-setup/mac.sh -o /tmp/ai-setup-mac.sh && bash /tmp/ai-setup-mac.sh
```

The script asks:
1. Who is this for? (Personal / Developer / Business)
2. What do you want to name your AI? (optional — press Enter to skip)

Then walk away. It handles everything.

### Windows

```powershell
# Open PowerShell as Administrator
irm https://gotlaptopparts.com/ai-setup/windows.ps1 -OutFile "$env:TEMP\ai-setup.ps1"; powershell -ExecutionPolicy Bypass -File "$env:TEMP\ai-setup.ps1"
```

Same questions. Same result.

### Requirements

- **Mac:** macOS 12+, 6GB+ RAM, 15GB+ free storage
- **Windows:** Windows 10/11, 6GB+ RAM, 15GB+ free storage, internet connection

---

## Security & Privacy

This script is fully open source. Every line is readable in this repository before you run it.

**What this script does:**
- Installs software via Homebrew (Mac) and winget (Windows) — both verified, signed package managers
- Downloads AI models from Ollama's official servers only
- Creates files in standard app locations and your Desktop
- Opens browser tabs for optional extensions

**What this script never does:**
- Does not collect your name, email, or any personal data
- Does not send anything to GotLaptopParts servers — ever
- Does not phone home or report usage
- Does not install tracking, analytics, or telemetry of any kind
- Does not modify system files outside standard app installation paths
- Does not require an account or login

**Your conversations are private:**
Once installed, AI runs entirely on your laptop. Your prompts, documents, and conversations never leave your device. No company — including GotLaptopParts — can see what you discuss with your AI.

**To verify before running:**
```bash
# Mac — read the script before executing it
curl -s https://gotlaptopparts.com/ai-setup/mac.sh > setup.sh
cat setup.sh   # read every line
bash setup.sh  # then run it
```

The tools we install (Ollama, LM Studio, Jan.ai, AnythingLLM) are independent open-source projects with their own privacy policies. Links: [Ollama](https://ollama.com/privacy) · [LM Studio](https://lmstudio.ai/privacy) · [Jan.ai](https://jan.ai/privacy) · [AnythingLLM](https://anythingllm.com/privacy).

---

## Frequently asked questions

**Is this script safe to run?**
The code is fully open source — read it before running. It only installs free, widely-used tools via verified package managers. It does not collect data, does not phone home, and does not modify system files outside standard paths.

**Does my data stay private?**
100%. Everything runs on your laptop. Your prompts, documents, and conversations never leave your machine. There are no accounts, no servers, no telemetry.

**Does it work without internet after setup?**
Yes. Once the model is downloaded, AI works completely offline — on planes, in remote areas, anywhere.

**What if something goes wrong?**
The script handles errors gracefully — retries downloads, auto-cleans storage, falls back to smaller models. If you get stuck: [gotlaptopparts.com/ai-setup/help](https://www.gotlaptopparts.com/ai-setup/help) or call (775) 203-1085.

**Can I choose a different AI model?**
Yes. Open LM Studio → Discover → browse 200+ models → download any with one click. No command line needed.

**Does it work on Apple Silicon (M1/M2/M3/M4)?**
Yes — and it works best on Apple Silicon. Metal GPU acceleration is automatic.

**What about NVIDIA GPU laptops?**
The script detects your NVIDIA GPU, updates drivers, and configures Ollama to use CUDA automatically.

**Can I uninstall everything?**
Yes. See the [Uninstall Guide](https://www.gotlaptopparts.com/ai-setup/uninstall).

**How do I update to a newer AI model?**
Open LM Studio → Discover → download the new model. Or run `ollama pull [model-name]` in Terminal.

**Is this affiliated with Ollama, LM Studio, or any AI company?**
No. Built and maintained by [GotLaptopParts.com](https://www.gotlaptopparts.com) (Laptop Mate LLC, Reno NV). All tools installed are independent open-source projects.

---

## For developers

Developer mode installs the full coding stack:

```
Ollama → LM Studio → Jan.ai → AnythingLLM → VS Code → Continue.dev → Cline
```

Continue.dev is pre-configured to use your local model via Ollama at `localhost:11434`. Drop-in replacement for GitHub Copilot — free, private, no rate limits. Cline gives you an agentic coding assistant that can read, write, and execute code across your project.

---

## Want a laptop with this pre-installed?

We sell refurbished laptops with everything pre-configured, model pre-downloaded, and verified running before shipping. Turn it on — AI works immediately.

→ [Shop AI-Ready Laptops](https://www.gotlaptopparts.com/ai-builds)

---

## Contributing

Found a bug? Open an issue. Better model recommendation? Submit a PR.

When contributing:
- Test on real hardware before submitting
- Keep hobbyist output simple — no technical jargon shown to general users
- Maintain the fallback chain — script must always find a working config
- Never add anything that phones home or collects data

---

## License

MIT — free to use, modify, and distribute. Attribution appreciated.

---

## Built by

[GotLaptopParts.com](https://www.gotlaptopparts.com) · Laptop Mate LLC · Reno, NV

We sell refurbished laptop parts and complete devices. We built this script because we believe everyone deserves private, free AI — regardless of whether they buy from us.

- Website: [gotlaptopparts.com](https://www.gotlaptopparts.com)
- AI Setup: [gotlaptopparts.com/ai-setup](https://www.gotlaptopparts.com/ai-setup)
- AI-Ready Laptops: [gotlaptopparts.com/ai-builds](https://www.gotlaptopparts.com/ai-builds)
- Used Laptops: [onlineusedlaptops.com](https://www.onlineusedlaptops.com)
- Phone: (775) 203-1085
