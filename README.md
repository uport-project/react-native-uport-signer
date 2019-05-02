
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
2. Go to `node_modules` ➜ `react-native-uport-signer` ➜ `ios` and add `RNUportSigner.xcodeproj`
3. Go to `node_modules` ➜ `react-native-uport-signer` ➜ `ios` ➜ `pods` and add `Pods.xcodeproj`
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


## HD Signer Usage
```javascript
import { RNUportHDSigner } from 'react-native-uport-signer';

// Create Seed
RNUportHDSigner.createSeed('simple').then( seed => {
	console.log(seed.address)
  console.log(seed.pubKey)
})

// Get the seed phrase
RNUportHDSigner.showSeed(address, 'simple').then (seed => {
	console.log(seed)
})

// Delete seed
RNUportHDSigner.deleteSeed(address)

// Import Seed
RNUportHDSigner.importSeed(seedPhrase, 'simple').then(addressObj => {
	console.log(addressObj.address)
	console.log(addressObj.pubKey)
})

//Derive another Address
RNUportHDSigner.addressForPath(address, `m/7696500'/0'/1'/0'`,'prompt').then (seed => {
	console.log(seed)
})

// Signing a JWT 
RNUportHDSigner.signJwt(address,
        RNUportHDSigner.UPORT_ROOT_DERIVATION_PATH,
        base64EncodedJwt,
        'simple'
    ).then( jwtSig => {
			console.log(jwtSig.r)
			console.log(jwtSig.s)
			console.log(jwtSig.v)
		})
		
// Signing an Eth Tx
RNUportHDSigner.signTx(address,
        RNUportHDSigner.UPORT_ROOT_DERIVATION_PATH,
        base64Tx,
        'simple'
    ).then( txSig => {
			console.log(txSig.r)
			console.log(txSig.s)
			console.log(txSig.v)
    })
```

## Basic Signer Usage (DEPRECATED)
Usage of the basic signer is discouraged because recovery is not possible.

```javascript
import { RNUportSigner } from 'react-native-uport-signer';

// Create a keypair
RNUportSigner.createKeyPair('simple').then(keypair => {
			console.log(keypair.address)
			console.log(keypar.pubKey)
})

//Sign a JWT
const exampleJwtPayload = { iss: address, aud: address, name: 'test'}

RNUportSigner.signJwt(address,
		exampleJwtPayload.toString('base64'), 
		'simple'
).then( jwtSig => {
	console.log(jwtSig.r)
	console.log(jwtSig.s)
	console.log(jwtSig.v)
})

//Sign an Eth tx
RNUportSigner.signTx(address,
        rlpEncodedTx, //RLP Encoded eth transaction
        'simple'
).then( txSig => {
	console.log(txSig.r)
	console.log(txSig.s)
	console.log(txSig.v)
})
		
```

## Changelog

* v1.2.1
    - android build based on kotlin 1.3.30
    - expose `listSeedAddresses` method on android