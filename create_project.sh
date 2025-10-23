#!/bin/bash

PROJECT="six-page-server"
echo "🚀 Creating project: $PROJECT"
mkdir -p $PROJECT
cd $PROJECT

# Create folders
mkdir -p templates static/css static/js

# -----------------------------
# app.py
# -----------------------------
cat << 'EOF' > app.py
from flask import Flask, render_template, request
import datetime

app = Flask(__name__)

@app.route('/')
def index():
    return render_template('index.html')

# Create routes for pages 1–6
for i in range(1, 7):
    def make_route(page_num):
        def route_func():
            if request.method == "POST":
                with open("submissions.log", "a") as f:
                    f.write(f"[{datetime.datetime.now()}] Page {page_num}: {request.form}\\n")
            return render_template(f"page{page_num}.html")
        route_func.__name__ = f"page{page_num}_route"
        app.add_url_rule(f"/page{page_num}", view_func=route_func, methods=["GET", "POST"])
    make_route(i)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
EOF

# -----------------------------
# templates/index.html
# -----------------------------
cat << 'EOF' > templates/index.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Home - Six Page Server</title>
    <link rel="stylesheet" href="{{ url_for('static', filename='css/global.css') }}">
</head>
<body>
    <div class="container">
        <h1>Welcome</h1>
        <p>Select a page:</p>
        <div class="button-grid">
            {% for i in range(1, 7) %}
                <button onclick="window.open('/page{{ i }}', '_blank')">Open Page {{ i }}</button>
            {% endfor %}
        </div>
    </div>
</body>
</html>
EOF

# -----------------------------
# Page templates
# -----------------------------
for i in {1..6}; do
cat << EOF > templates/page${i}.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Page ${i}</title>
    <link rel="stylesheet" href="{{ url_for('static', filename='css/global.css') }}">
    <link rel="stylesheet" href="{{ url_for('static', filename='css/page${i}.css') }}">
</head>
<body>
    <div class="container">
        <h1>Page ${i}</h1>
        <form method="POST">
            <label for="input${i}">Enter something:</label>
            <input id="input${i}" name="input${i}" placeholder="Type here..." required>
            <button type="submit">Submit</button>
        </form>
    </div>
    <script src="{{ url_for('static', filename='js/page${i}.js') }}"></script>
</body>
</html>
EOF
done

# -----------------------------
# global.css
# -----------------------------
cat << 'EOF' > static/css/global.css
body {
  font-family: Arial, sans-serif;
  margin: 0;
  background: linear-gradient(135deg, #f0f4ff, #d9e8ff);
  display: flex;
  justify-content: center;
  align-items: center;
  height: 100vh;
}
.container {
  background: white;
  padding: 30px;
  border-radius: 16px;
  box-shadow: 0 4px 10px rgba(0,0,0,0.1);
  text-align: center;
}
button {
  background: #007bff;
  border: none;
  color: white;
  padding: 10px 20px;
  border-radius: 8px;
  cursor: pointer;
  margin: 5px;
  transition: background 0.3s;
}
button:hover {
  background: #0056b3;
}
input {
  padding: 8px;
  border: 1px solid #ccc;
  border-radius: 6px;
  width: 80%;
  margin: 10px 0;
}
.button-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 10px;
  margin-top: 20px;
}
EOF

# -----------------------------
# Page-specific CSS + JS
# -----------------------------
for i in {1..6}; do
echo "/* Page ${i} specific styles */" > static/css/page${i}.css
echo "// Page ${i} JS logic" > static/js/page${i}.js
done

# -----------------------------
# start.sh
# -----------------------------
cat << 'EOF' > start.sh
#!/bin/bash
export FLASK_APP=app.py

# Replace this with your real token
NGROK_TOKEN="YOUR_NGROK_TOKEN_HERE"

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
EOF

chmod +x start.sh
echo "flask" > requirements.txt
touch submissions.log

echo "✅ Project '$PROJECT' created successfully!"
echo "Next steps:"
echo "  cd $PROJECT"
echo "  pip install -r requirements.txt"
echo "  ./start.sh"
