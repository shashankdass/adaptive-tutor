# 🧠 Adaptive Tutor

An AI-driven adaptive learning app built with Streamlit. Pick a subject, answer
generated questions, and the difficulty adapts to your performance.

It runs against **either** backend automatically:

| Environment | Backend | How it's chosen |
|-------------|---------|-----------------|
| Local dev   | **Ollama** (local Llama 3) | default, no key needed |
| Cloud       | **Groq** (free hosted Llama 3) | used when `GROQ_API_KEY` is set |

## Run locally (Ollama)

```bash
python3 -m venv .venv
.venv/bin/pip install -r requirements.txt
ollama serve            # in another terminal
ollama pull llama3
.venv/bin/streamlit run app.py
```

## Deploy free to Streamlit Community Cloud (Groq)

Free cloud instances can't run an 8B model locally, so the cloud deploy uses
Groq's free Llama 3 API instead — no code changes needed.

1. Push this repo to GitHub.
2. Get a free Groq API key: <https://console.groq.com/keys>
3. Go to <https://share.streamlit.io> → **New app** → pick this repo, `app.py`.
4. Under **Advanced settings → Secrets**, paste:
   ```toml
   GROQ_API_KEY = "gsk_your_key_here"
   ```
5. Deploy. Every `git push` to the default branch auto-redeploys.

## Configuration

Set via Streamlit secrets (cloud) or environment variables (local):

- `GROQ_API_KEY` — presence switches the app to the Groq backend.
- `LLM_MODEL` — override the model (e.g. `llama-3.1-8b-instant` / `llama3`).
- `LLM_BACKEND` — force `"groq"` or `"ollama"`.

## Files

- `app.py` — the whole app (UI, curriculum, adaptivity, LLM backends).
- `chat_app.py` — an earlier simple chat demo (not part of the tutor).
