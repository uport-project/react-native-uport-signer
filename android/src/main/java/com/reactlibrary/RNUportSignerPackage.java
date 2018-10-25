
package com.reactlibrary;

import java.util.Arrays;
import java.util.Collections;
import java.util.List;

public class RNUportSignerPackage implements ReactPackage {

    @Override
    public List<NativeModule> createNativeModules(ReactApplicationContext reactContext) {
      List<NativeModule> modules = new ArrayList<>();

      modules.add(new RNUportSignerModule(reactContext));
      return modules;
    }
    // Deprecated from RN 0.47
    public List<Class<? extends JavaScriptModule>> createJSModules() {
      return Collections.emptyList();
    }

    @Override
    public List<ViewManager> createViewManagers(ReactApplicationContext reactContext) {
      return Collections.emptyList();
    }
}