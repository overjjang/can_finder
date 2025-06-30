# ML Kit Text Recognition 관련 클래스 보존
-keep class com.google.mlkit.vision.text.** { *; }
-keep class com.google.mlkit.vision.common.** { *; }
-keep class com.google.mlkit.common.** { *; }

# 한국어, 일본어, 중국어, 데바나가리 문자 인식 옵션 클래스 보존
-keep class com.google.mlkit.vision.text.korean.** { *; }
-keep class com.google.mlkit.vision.text.japanese.** { *; }
-keep class com.google.mlkit.vision.text.chinese.** { *; }
-keep class com.google.mlkit.vision.text.devanagari.** { *; }

# Google Play 서비스 관련 클래스 보존 (필요한 경우)
-keep class com.google.android.gms.** { *; }

# Firebase ML Kit이 내부적으로 사용하는 리플렉션 클래스 보호
-keep class com.google.firebase.components.ComponentRegistrar
-keep class com.google.firebase.** { *; }

# 기타 Flutter 플러그인이 사용하는 클래스 보호
-keep class io.flutter.embedding.engine.FlutterEngine { *; }
-keep class io.flutter.plugin.** { *; }

# 기본적으로 모든 애플리케이션 클래스 보호
-keep class com.example.can_fluter_finder.** { *; }
