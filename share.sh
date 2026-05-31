#!/usr/bin/env bash
# Expose the local Streamlit app (port 8501) publicly via ngrok.
#
# One-time setup (free ngrok account):
#   1. Sign up:  https://dashboard.ngrok.com/signup
#   2. Token:    https://dashboard.ngrok.com/get-started/your-authtoken
#   3. Run:      ngrok config add-authtoken YOUR_TOKEN
#
# Then just:  ./share.sh
set -euo pipefail

PORT=8501
APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 1. Make sure ngrok is authenticated.
if ! ngrok config check >/dev/null 2>&1; then
  echo "❌ ngrok has no authtoken yet."
  echo "   Get one at https://dashboard.ngrok.com/get-started/your-authtoken"
  echo "   then run:  ngrok config add-authtoken YOUR_TOKEN"
  exit 1
fi

# 2. Make sure the Ollama server is up.
if ! curl -s "http://localhost:11434/api/version" >/dev/null 2>&1; then
  echo "▶️  Starting Ollama server..."
  ollama serve >/tmp/ollama-serve.log 2>&1 &
  sleep 3
fi

# 3. (Re)start Streamlit with tunnel-friendly settings.
#    Disabling XSRF/CORS avoids the "Please wait..." hang some users hit
#    when Streamlit is accessed through a proxy/tunnel.
pkill -f "streamlit run app.py" 2>/dev/null || true
sleep 1
echo "▶️  Starting Streamlit on port $PORT..."
.venv/bin/streamlit run "$APP_DIR/app.py" \
  --server.headless true \
  --server.port "$PORT" \
  --server.enableCORS false \
  --server.enableXsrfProtection false \
  >/tmp/streamlit.log 2>&1 &

# Wait for Streamlit to respond.
for _ in $(seq 1 20); do
  if curl -s -o /dev/null "http://localhost:$PORT"; then break; fi
  sleep 1
done

# 4. Open the public tunnel (foreground — Ctrl-C to stop sharing).
echo "🌍 Opening public tunnel. Share the https URL printed below."
echo "   Press Ctrl-C to stop sharing (the app keeps running locally)."
echo
exec ngrok http "$PORT"
