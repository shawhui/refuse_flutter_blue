package com.pauldemarco.refuse_flutter_blue_example;

import android.os.Bundle;
import dev.flutter.plugins.e2e.E2EPlugin;
import io.flutter.app.FlutterActivity;
import com.pauldemarco.refuse_flutter_blue.FlutterBluePlugin;

public class EmbeddingV1Activity extends FlutterActivity {
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    FlutterBluePlugin.registerWith(registrarFor("com.pauldemarco.refuse_flutter_blue.FlutterBluePlugin"));
    E2EPlugin.registerWith(registrarFor("dev.flutter.plugins.e2e.E2EPlugin"));
  }
}
