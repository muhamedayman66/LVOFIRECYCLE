from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.responses import JSONResponse
import uvicorn
import shutil
import os
import tensorflow as tf
import numpy as np
import uuid
import logging
from PIL import Image


logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


MODEL_PATH = r"G:/IT/Year4/Graduation Project/AI/Model/best_model.keras"
CLASS_NAMES = ['Aluminum Can', 'Glass Bottle', 'Plastic Bottle']

try:
    model = tf.keras.models.load_model(MODEL_PATH)
    logger.info("Model loaded successfully!")
except Exception as e:
    logger.error(f"Error loading model: {e}")
    model = None

app = FastAPI()


from fastapi.middleware.cors import CORSMiddleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

UPLOAD_DIR = os.path.join(os.getcwd(), "uploads")
os.makedirs(UPLOAD_DIR, exist_ok=True)


def preprocess_image_pil(file_path):
    img_size = (224, 224)

 
    img = Image.open(file_path)
    
 
    img = img.convert("RGB")  
    img = img.resize(img_size)  
    
   
    img_array = np.array(img) / 255.0  
    img_array = np.expand_dims(img_array, axis=0)  
    return img_array

@app.post("/predict/")
async def predict(file: UploadFile = File(...)):
    if not model:
        raise HTTPException(status_code=500, detail="Model not loaded.")
    
    if not file.filename.lower().endswith((".png", ".jpg", ".jpeg")):
        raise HTTPException(status_code=400, detail="Invalid file format. Only JPG, JPEG, and PNG are supported.")

    file_extension = file.filename.split(".")[-1]
    unique_filename = f"{uuid.uuid4()}.{file_extension}"
    file_path = os.path.join(UPLOAD_DIR, unique_filename)

    try:
        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)

        img_array = preprocess_image_pil(file_path)

     
        predictions = model.predict(img_array)
        predicted_class = np.argmax(predictions, axis=1)[0]
        predicted_label = CLASS_NAMES[predicted_class]
        confidence = float(predictions[0][predicted_class])

        logger.info(f"Prediction: {predicted_label} | Confidence: {confidence}")

        return JSONResponse(content={"prediction": predicted_label, "confidence": confidence})

    except Exception as e:
        logger.error("Error: " + str(e))
        raise HTTPException(status_code=500, detail="Failed to classify image")

    finally:
        try:
            os.remove(file_path)
        except Exception as e:
            logger.warning(f"Failed to delete {file_path}: {e}")

if __name__ == "__main__":
    uvicorn.run(app, host="192.168.1.7", port=8000)
