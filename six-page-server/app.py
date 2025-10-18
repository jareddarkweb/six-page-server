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
