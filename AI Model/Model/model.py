import tensorflow as tf
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Dense, Dropout, GlobalAveragePooling2D
from tensorflow.keras.applications import MobileNetV2
from tensorflow.keras.regularizers import l2

def create_model(input_shape=(224, 224, 3), num_classes=3):
    base_model = MobileNetV2(weights="imagenet", include_top=False, input_shape=input_shape)
    
   
    base_model.trainable = True
    for layer in base_model.layers[:-5]:
        layer.trainable = False
    
    model = Sequential([
        base_model,
        GlobalAveragePooling2D(),
        
        Dropout(0.5), 
        Dense(128, activation="relu", kernel_regularizer=l2(0.01)),
        Dropout(0.5),
        
        Dense(num_classes, activation="softmax")
    ])

    model.compile(optimizer=tf.keras.optimizers.Adam(learning_rate=1e-4),  
                  loss="categorical_crossentropy", 
                  metrics=["accuracy"])
    
    return model