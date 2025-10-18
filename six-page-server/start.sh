#!/bin/bash
export FLASK_APP=app.py

# Replace this with your real token
NGROK_TOKEN="1t2k5n8CBN89itFjn3sqMQ13ToP_7ghEuqU27RNutnXVUa6pV"

# Start Flask
echo "🚀 Starting Flask server..."
python3 app.py &
FLASK_PID=$!

# Wait a moment
sleep 3

# Start ngrok
echo "🌐 Starting ngrok tunnel..."
ngrok config add-authtoken $NGROK_TOKEN
ngrok http 5000
kill $FLASK_PID
