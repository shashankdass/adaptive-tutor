"""A simple ChatGPT-like chat UI powered by a local Llama 3 model via Ollama.

Run with:
    streamlit run app.py

Requires the Ollama server to be running (`ollama serve`) and the model pulled
(`ollama pull llama3`).
"""

import ollama
import streamlit as st

MODEL = "llama3"

st.set_page_config(page_title="Local Llama 3 Chat", page_icon="🦙")
st.title("🦙 Local Llama 3 Chat")
st.caption(f"Powered by Ollama · model: `{MODEL}`")

# Initialize chat history in session state.
if "messages" not in st.session_state:
    st.session_state.messages = []

# Sidebar with a button to clear the conversation.
with st.sidebar:
    if st.button("🗑️  Clear chat", use_container_width=True):
        st.session_state.messages = []
        st.rerun()

# Replay the conversation so far.
for message in st.session_state.messages:
    with st.chat_message(message["role"]):
        st.markdown(message["content"])

# Handle a new user message.
if prompt := st.chat_input("Ask anything…"):
    st.session_state.messages.append({"role": "user", "content": prompt})
    with st.chat_message("user"):
        st.markdown(prompt)

    # Stream the assistant's reply token by token.
    with st.chat_message("assistant"):
        try:
            stream = ollama.chat(
                model=MODEL,
                messages=st.session_state.messages,
                stream=True,
            )
            response = st.write_stream(
                chunk["message"]["content"] for chunk in stream
            )
        except Exception as exc:  # noqa: BLE001
            response = (
                f"⚠️ Could not reach Ollama. Is the server running and is the "
                f"`{MODEL}` model pulled?\n\n```\n{exc}\n```"
            )
            st.markdown(response)

    st.session_state.messages.append({"role": "assistant", "content": response})
