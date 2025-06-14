import tensorflow as tf
import numpy as np
from tensorflow.keras.preprocessing import image


MODEL_PATH = r"G:/IT/Year4/Graduation Project/AI/Model/best_model.keras"
CLASS_NAMES = ["Aluminum Can", "Glass Bottle", "Plastic Bottle"]

try:
    model = tf.keras.models.load_model(MODEL_PATH)
    print("Model loaded successfully!")
except Exception as e:
    print(f"rror loading model: {e}")
    model = None

def preprocess_image(img_path):
    try:
        img = image.load_img(img_path, target_size=(224, 224))
        img_array = image.img_to_array(img, dtype=np.float32) / 255.0
        img_array = np.expand_dims(img_array, axis=0)  
        return img_array
    except Exception as e:
        print(f"Error in image preprocessing: {e}")
        return None

def predict_image(img_path):
    if model is None:
        return {"class": "Model not loaded", "confidence": 0.0}
    
    try:
        img_array = preprocess_image(img_path)
        if img_array is None:
            return {"class": "Unknown", "confidence": 0.0}
        
        predictions = model.predict(img_array, verbose=0)
        predicted_class = CLASS_NAMES[np.argmax(predictions)]
        confidence = round(float(np.max(predictions) * 100), 2)
        
        return {"class": predicted_class, "confidence": confidence}
    except Exception as e:
        print(f"Error in prediction: {e}")
        return {"class": "Unknown", "confidence": 0.0}