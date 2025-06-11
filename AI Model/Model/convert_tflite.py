import tensorflow as tf

# تحميل الموديل المدرب
model = tf.keras.models.load_model("best_model.keras")

# تحويل الموديل إلى TFLite
converter = tf.lite.TFLiteConverter.from_keras_model(model)
tflite_model = converter.convert()

# حفظ الموديل المحول
with open("best_model.tflite", "wb") as f:
    f.write(tflite_model)

print("تم التحويل بنجاح إلى best_model.tflite")
