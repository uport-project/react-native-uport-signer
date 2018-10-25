
# react-native-uport-signer

## Getting started

`$ npm install react-native-uport-signer --save`

### Mostly automatic installation

`$ react-native link react-native-uport-signer`

### Manual installation


#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-uport-signer` and add `RNUportSigner.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libRNUportSigner.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Run your project (`Cmd+R`)<

#### Android

1. Open up `android/app/src/main/java/[...]/MainActivity.java`
  - Add `import com.reactlibrary.RNUportSignerPackage;` to the imports at the top of the file
  - Add `new RNUportSignerPackage()` to the list returned by the `getPackages()` method
2. Append the following lines to `android/settings.gradle`:
  	```
  	include ':react-native-uport-signer'
  	project(':react-native-uport-signer').projectDir = new File(rootProject.projectDir, 	'../node_modules/react-native-uport-signer/android')
  	```
3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:
  	```
      compile project(':react-native-uport-signer')
  	```

#### Windows
[Read it! :D](https://github.com/ReactWindows/react-native)

1. In Visual Studio add the `RNUportSigner.sln` in `node_modules/react-native-uport-signer/windows/RNUportSigner.sln` folder to their solution, reference from their app.
2. Open up your `MainPage.cs` app
  - Add `using Uport.Signer.RNUportSigner;` to the usings at the top of the file
  - Add `new RNUportSignerPackage()` to the `List<IReactPackage>` returned by the `Packages` method


## Usage
```javascript
import RNUportSigner from 'react-native-uport-signer';

// TODO: What to do with the module?
RNUportSigner;
```
  