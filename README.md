
# react-native-uport-signer

## Getting started

`$ npm install react-native-uport-signer --save`

### Mostly automatic installation

1. `$ react-native link react-native-uport-signer`
2. Insert the following line inside the `allprojects.repositories` block in `android/build.gradle`:
```groovy
allprojects {
  repositories {
      //...
      //add this line
      maven { url 'https://jitpack.io' }
  }
}
```

### Manual installation


#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-uport-signer` and add `RNUportSigner.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libRNUportSigner.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Run your project (`Cmd+R`)<

#### Android

1. Insert the following line inside the `allprojects.repositories` block in `android/build.gradle`:

```groovy
allprojects {
   repositories {
       //...
       //add this line
       maven { url 'https://jitpack.io' }
   }
}
```
2. Insert the following lines inside the `dependencies` block in `android/app/build.gradle`:
```groovy
dependencies {
    // add this line
    implementation project(':react-native-uport-signer')
    //...
}
```

3. Append the following lines to `android/settings.gradle`:
```groovy
include ':react-native-uport-signer'
project(':react-native-uport-signer').projectDir = new File(rootProject.projectDir, 	'../node_modules/react-native-uport-signer/android')
```

4. Open up `android/app/src/main/java/[...]/MainActivity.java`
  - Add `import com.reactlibrary.RNUportSignerPackage;` to the imports at the top of the file
  - Add `new RNUportSignerPackage()` to the list returned by the `getPackages()` method
  
5. [optional] If not already done, update the `minSdkVersion` of your `app` to 21
  This is usually in `android/app/build.gradle` but can also be defined in `android/build.gradle`
depending on when your project was created


## Usage
```javascript
import RNUportSigner from 'react-native-uport-signer';

// TODO: What to do with the module?
RNUportSigner;
```
  