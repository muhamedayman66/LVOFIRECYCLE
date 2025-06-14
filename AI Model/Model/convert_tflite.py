import tensorflow as tf


model = tf.keras.models.load_model("best_model.keras")
converter = tf.lite.TFLiteConverter.from_keras_model(model)
tflite_model = converter.convert()


with open("best_model.tflite", "wb") as f:
    f.write(tflite_model)

print("تم التحويل بنجاح إلى best_model.tflite")
