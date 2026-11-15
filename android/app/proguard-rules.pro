# ML Kit text recognition: only the Latin model is bundled. The plugin still
# references the optional Chinese/Devanagari/Japanese/Korean modules, which
# are intentionally not included.
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**
