import os
import sys
import torch
import numpy as np
from PIL import Image
import rembg
import trimesh

# Add triposr_repo to sys.path to allow importing tsr
REPO_PATH = os.path.join(os.path.dirname(__file__), "triposr_repo")
if REPO_PATH not in sys.path:
    sys.path.append(REPO_PATH)

from tsr.system import TSR
from tsr.utils import remove_background, resize_foreground

def log_to_file(msg):
    with open("backend_log.txt", "a") as f:
        f.write(f"{msg}\n")
    print(msg)

class LocalTSRService:
    def __init__(self, device=None):
        if device is None:
            self.device = "cuda:0" if torch.cuda.is_available() else "cpu"
        else:
            self.device = device
            
        print(f"Initializing Local TSR on {self.device}...")
        
        self.model = TSR.from_pretrained(
            "stabilityai/TripoSR",
            config_name="config.yaml",
            weight_name="model.ckpt",
        )
        self.model.renderer.set_chunk_size(8192)
        self.model.to(self.device)
        self.rembg_session = rembg.new_session()
        print("Local TSR Engine Ready.")

    def run_inference(self, input_image_path, output_glb_path, is_full_room=False):
        log_to_file(f"--- run_inference started ---")
        log_to_file(f"Input: {input_image_path}")
        log_to_file(f"Output: {output_glb_path}")
        try:
            # 1. Load image
            if not os.path.exists(input_image_path):
                log_to_file(f"!!! Error: Input file does not exist: {input_image_path}")
                return False
                
            img = Image.open(input_image_path)
            log_to_file(f"Image loaded: {img.size} {img.mode}")
            
            if not is_full_room:
                log_to_file("Processing Object Mode (Background Removal)...")
                # Object Mode: Remove background
                img = remove_background(img, self.rembg_session)
                img = resize_foreground(img, 0.85)
                
                img_array = np.array(img).astype(np.float32) / 255.0
                img_final = img_array[:, :, :3] * img_array[:, :, 3:4] + (1 - img_array[:, :, 3:4]) * 0.5
                processed_img = Image.fromarray((img_final * 255.0).astype(np.uint8))
            else:
                log_to_file("Processing Room Mode (Structure-Aware)...")
                # Enhance room features
                from PIL import ImageEnhance
                enhancer = ImageEnhance.Contrast(img)
                processed_img = enhancer.enhance(1.1).resize((512, 512))
            
            # 2. Run model
            log_to_file("Running AI Model (TSR)...")
            with torch.no_grad():
                scene_codes = self.model([processed_img], device=self.device)
            
            # 3. Extract mesh
            # SPEED OPTIMIZATION: Reduce resolution to 128 for rooms to get under 1 minute
            log_to_file(f"Extracting Mesh (Mode: {'Room' if is_full_room else 'Object'})...")
            
            if is_full_room:
                 threshold = 12.0 # Slightly higher to reduce noise
                 res = 160        # Much faster than 256/384
            else:
                 threshold = 25.0
                 res = 128

            meshes = self.model.extract_mesh(scene_codes, True, resolution=res, threshold=threshold)
            
            if not meshes or len(meshes) == 0:
                log_to_file("!!! Error: No meshes extracted!")
                return False
                
            # 4. Export to GLB
            log_to_file(f"Processing and Exporting...")
            mesh = meshes[0]
            
            # SIMPLIFICATION: Reduce triangle count for instant web loading
            # Target ~20k triangles (from 180k+)
            target_faces = 20000
            if len(mesh.faces) > target_faces:
                log_to_file(f"Simplifying mesh from {len(mesh.faces)} to {target_faces} faces...")
                mesh = mesh.simplify_quadric_decimation(target_faces)

            # SMOOTHING
            import trimesh.smoothing
            trimesh.smoothing.filter_taubin(mesh, iterations=1)
            
            # ROOM ORIENTATION
            if is_full_room:
                # Standard TripoSR room alignment
                mesh.apply_transform(trimesh.transformations.rotation_matrix(np.deg2rad(-90), [1, 0, 0]))
                mesh.apply_scale(1.5) 
            
            # CENTERING
            mesh.apply_translation(-mesh.centroid) 
            
            # Export
            mesh.export(output_glb_path)
            
            log_to_file(f"--- run_inference success (Size: {len(mesh.vertices)} verts, {len(mesh.faces)} faces) ---")
            return True
        except Exception as e:
            import traceback
            log_to_file(f"!!! Inference Error: {e}")
            log_to_file(traceback.format_exc())
            return False
