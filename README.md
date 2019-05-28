
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

3. [optional] If not already done, update the `minSdkVersion` of your `app` to 21
  This is usually in `android/app/build.gradle` but can also be defined in `android/build.gradle`
depending on when your project was created

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

`RNUportHDSigner` provides a mechanism of importing or creating seeds that can be used to derive
keys for signing.
Seeds are encrypted using platform specific hardware backed encryption and can be extra protected
by fingerprint/keyguard.

Keys are derived every time they are used to sign or to compute addresses.

### creating or importing seeds

```javascript
import { RNUportHDSigner } from 'react-native-uport-signer';

var seedAlias = ""

// Create a new seed
RNUportHDSigner.createSeed('prompt').then( addressObj => {
  //keep a record of it to reference the seed when signing
  seedAlias = addressObj.address
})

// Import a seed using a previously saved phrase
RNUportHDSigner.importSeed(phrase, 'simple').then(addressObj => {
	//keep a record of it to reference the seed when signing
    seedAlias = addressObj.address
})

// Delete seed
RNUportHDSigner.deleteSeed(seedAlias)

```

Depending on the protection level *chosen during seed creation or import*, the user may be prompted
to use their fingerprint or device PIN to unlock the seed.
Relevant methods allow you to provide a message to the user about what it is they are signing.

Protection levels:

* `'simple'` - seeds are encrypted but don't require user auth to be used
* `'prompt'` - seeds are encrypted and need fingerprint or keyguard unlocking.
* `'singleprompt'` - seeds are encrypted and need keyguard to unlock but only once every 30 seconds

The last 2 cases bring up the fingerprint or device keyguard UI *every time* a seed/key is used.

### revealing the recovery phrase

The seed phrase can be revealed (and later used for recovery using `importSeed`).
It is a sequence of 12 words, a commonly used recovery pattern in the crypto space.

```javascript

// Get the seed phrase
RNUportHDSigner.showSeed(seedAlias, 'Reveal the recovery phrase').then (phrase => {
	// have the user write down the phrase
})
```

### key derivation paths

When signing, you need to specify a derivation path that will be used to generate the key.
If you need to know the ethereum address or public key corresponding to that key, it can be 
revealed using `addressForPath()`.
This needs to be done only once since the address is deterministic.

Some example paths:

* `m/44'/60'/0'/0/0` - commonly used by ethereum wallet apps (metamask, trezor, jaxx...)
* `m/7696500'/0'/0'/0'` - uport root account path

```javascript

//Derive another Address
RNUportHDSigner.addressForPath(seedAlias, `m/44'/60'/0'/0/0`, 'Create a new address').then (addressObj => {
	console.log(addressObj.address)
    console.log(addressObj.pubKey)
})

```

### signing

You can sign ethereum transactions and JWT payloads: 

```javascript
// Signing a JWT
RNUportHDSigner.signJwt(seedAlias,
        RNUportHDSigner.UPORT_ROOT_DERIVATION_PATH,
        base64EncodedJwt,
        'Sign a claim'
    ).then( jwtSig => {
			console.log(jwtSig.r)
			console.log(jwtSig.s)
			console.log(jwtSig.v)
		})
		
// Signing an Eth Tx
RNUportHDSigner.signTx(address,
        `m/44'/60'/0'/0/0`,
        base64EncodedTx,
        'Sign an ETH transaction'
    ).then( txSig => {
			console.log(txSig.r)
			console.log(txSig.s)
			console.log(txSig.v)
    })
```

## Basic Signer Usage (DEPRECATED)
Usage of the basic signer is discouraged because recovery of the keys is not possible.
Keys can be imported but this is not a secure practice.
Any key recovery mechanism is outside the scope of the basic signer (`RNUportSigner`).
Please use the HD signer, `RNUportHDSigner`

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
		'Sign a JWT'
).then( jwtSig => {
	console.log(jwtSig.r)
	console.log(jwtSig.s)
	console.log(jwtSig.v)
})

//Sign an Eth tx
RNUportSigner.signTx(address,
        rlpEncodedTx, //RLP Encoded eth transaction
        'Sign an ETH transaction'
).then( txSig => {
	console.log(txSig.r)
	console.log(txSig.s)
	console.log(txSig.v)
})
		
```

## Changelog
* 1.3.3
  - [Android] bugfix - fix silent errors when signing JWT
   
* 1.3.2
  - [Android] remove createJSModules override to work with react-native > 0.47 
  
* 1.3.1
  - [iOS] fix search path for valet

* 1.3.0
  - [iOS] replaces usage of CoreEthereum -> EthCore
  - [iOS] Adds requiresMainQueueSetup method to get rid of react-native yellowbox warning
  - [Android] Correctly scales recovery param for JWT's on android
  - [Android] Methods use an activity context when available
  
* v1.2.1
    - android build based on kotlin 1.3.30
    - expose `listSeedAddresses` method on android