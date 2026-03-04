from flask import Flask, request, jsonify, send_from_directory
from flask_cors import CORS
import os
import uuid
import base64
import threading
import requests
import shutil
from local_inference import LocalTSRService

app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "*"}}, supports_credentials=True)

def log_to_file(msg):
    with open("backend_log.txt", "a") as f:
        f.write(f"{msg}\n")
    print(msg)

log_to_file("--- SERVER RESTARTED ---")

@app.route('/')
def home():
    log_to_file("Home route accessed")
    return "<h1>Decora Local AI Backend is ONLINE</h1><p>Running on CPU/GPU</p>"

# Setup directories
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
INPUT_DIR = os.path.join(BASE_DIR, "inputs")
OUTPUT_DIR = os.path.join(BASE_DIR, "outputs")
os.makedirs(INPUT_DIR, exist_ok=True)
os.makedirs(OUTPUT_DIR, exist_ok=True)

# Initialize Local AI Service
tsr_service = None

def init_ai():
    global tsr_service
    try:
        tsr_service = LocalTSRService()
        log_to_file("Local TSR Engine Ready")
    except Exception as e:
        log_to_file(f"!!! Error Initializing AI Service: {e}")

threading.Thread(target=init_ai).start()

@app.route('/api/predict', methods=['POST'])
def predict():
    log_to_file("Predict request received")
    try:
        data = request.json
        if not data or 'input' not in data:
            return jsonify({"error": "Invalid request"}), 400
            
        # Extract image (can be base64 or URL)
        image_data = data['input'].get('image')
        if not image_data:
            return jsonify({"error": "No image found in input"}), 400
            
        # Generate Unique ID
        job_id = str(uuid.uuid4())
        input_path = os.path.join(INPUT_DIR, f"{job_id}.png")
        output_path = os.path.join(OUTPUT_DIR, f"{job_id}.glb")

        # Optimization: If the image is a URL from OUR OWN server, just copy it!
        is_local_copy = False
        if isinstance(image_data, str) and "/outputs/" in image_data:
            local_filename = image_data.split("/outputs/")[-1]
            local_source_path = os.path.join(OUTPUT_DIR, local_filename)
            if os.path.exists(local_source_path):
                 log_to_file(f"--- Using local source for {job_id}: {local_source_path}")
                 if local_filename.lower().endswith((".png", ".jpg", ".jpeg")):
                     shutil.copy(local_source_path, input_path)
                     is_local_copy = True

        if not is_local_copy:
            if isinstance(image_data, str) and image_data.startswith('http'):
                # Download from URL
                log_to_file(f"--- Downloading image from: {image_data}")
                try:
                    r = requests.get(image_data, stream=True, timeout=15)
                    r.raise_for_status()
                    with open(input_path, 'wb') as f:
                        for chunk in r.iter_content(1024):
                            f.write(chunk)
                except Exception as e:
                     log_to_file(f"!!! Failed to download: {e}")
                     return jsonify({"error": f"Failed to download image: {str(e)}"}), 400
            else:
                # Handle Base64
                try:
                    b64_str = image_data
                    if "base64," in b64_str:
                        b64_str = b64_str.split("base64,")[1]
                    
                    log_to_file(f"--- Saving base64 image to: {input_path}")
                    with open(input_path, "wb") as f:
                        f.write(base64.b64decode(b64_str))
                except Exception as e:
                    log_to_file(f"!!! Base64 decode error: {e}")
                    return jsonify({"error": "Invalid base64 data"}), 400
            
        is_full_room = data['input'].get('is_full_room', False)
        
        # Start Inference in background
        def run_task():
            if tsr_service:
                log_to_file(f">>> Starting Local Inference for {job_id} (Full Room: {is_full_room})")
                success = tsr_service.run_inference(input_path, output_path, is_full_room=is_full_room)
                if success:
                    log_to_file(f"<<< Inference Complete for {job_id}")
                else:
                    log_to_file(f"!!! Inference Failed for {job_id}")
            else:
                log_to_file("!!! AI Service not ready yet.")

        threading.Thread(target=run_task).start()
        
        return jsonify({
            "id": job_id,
            "status": "processing",
            "urls": {
                "get": f"{request.host_url}api/poll?id={job_id}"
            }
        }), 201

    except Exception as e:
        log_to_file(f"!!! Predict Error: {e}")
        return jsonify({"error": str(e)}), 500

@app.route('/api/poll', methods=['GET'])
def poll():
    job_id = request.args.get('id')
    log_to_file(f"Polling check for job_id: {job_id}")
    if not job_id:
        return jsonify({"error": "Missing id"}), 400
        
    output_filename = f"{job_id}.glb"
    output_path = os.path.join(OUTPUT_DIR, output_filename)
    
    if os.path.exists(output_path):
        return jsonify({
            "id": job_id,
            "status": "succeeded",
            "output": [f"{request.host_url}outputs/{output_filename}"]
        })
    else:
        # Safety check: if input file doesn't exist, the job definitely failed or was lost
        input_path = os.path.join(INPUT_DIR, f"{job_id}.png")
        if not os.path.exists(input_path):
             return jsonify({"status": "failed", "error": "Job path not found"}), 404
             
        return jsonify({
            "id": job_id,
            "status": "processing"
        })

@app.route('/outputs/<path:filename>')
def serve_output(filename):
    try:
        response = send_from_directory(OUTPUT_DIR, filename)
        # Extreme CORS for development
        response.headers['Access-Control-Allow-Origin'] = '*'
        response.headers['Access-Control-Allow-Methods'] = 'GET, OPTIONS'
        response.headers['Access-Control-Allow-Headers'] = '*'
        response.headers['Cache-Control'] = 'no-cache, no-store, must-revalidate'
        
        if filename.endswith('.glb'):
            response.mimetype = 'model/gltf-binary'
        return response
    except Exception as e:
        log_to_file(f"!!! Error serving file {filename}: {e}")
        return "File not found", 404

@app.after_request
def after_request(response):
    response.headers.add('Access-Control-Allow-Origin', '*')
    response.headers.add('Access-Control-Allow-Headers', 'Content-Type,Authorization')
    response.headers.add('Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE,OPTIONS')
    return response

@app.route('/api/health', methods=['GET'])
def health():
    return jsonify({
        "status": "online",
        "ip": "192.168.220.14",
        "message": "Computer is reachable from phone!"
    })

if __name__ == '__main__':
    log_to_file("--- Backend starting on port 5000 ---")
    app.run(host='0.0.0.0', port=5000, debug=False)
