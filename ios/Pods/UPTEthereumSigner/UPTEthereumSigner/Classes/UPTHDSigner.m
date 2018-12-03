//
//  UPTHDSigner.m
//  uPortMobile
//
//  Created by josh on 1/5/18.
//  Copyright © 2018 ConsenSys AG. All rights reserved.
//

#import "UPTHDSigner.h"
#import "EthereumSigner.h"
#import "CoreBitcoin/BTCMnemonic.h"
#import "keccak.h"
#import "CoreBitcoin/CoreBitcoin+Categories.h"
#import <Valet/Valet.h>

// https://github.com/ethereum/EIPs/issues/84
NSString * const UPORT_ROOT_DERIVATION_PATH = @"m/7696500'/0'/0'/0'";
NSString * const METAMASK_ROOT_DERIVATION_PATH = @"m/44'/60'/0'/0";

/// @description identifiers so valet can encapsulate our keys in the keychain
NSString *const UPTHDPrivateKeyIdentifier = @"UportPrivateKeys";
NSString *const UPTHDProtectionLevelIdentifier = @"UportProtectionLevelIdentifier";
NSString *const UPTHDAddressIdentifier = @"UportEthAddressIdentifier";

/// @desctiption the key prefix to concatenate with the eth address necessary to lookup the private key
NSString *const UPTHDEntropyLookupKeyNamePrefix = @"seed-";
NSString *const UPTHDEntropyProtectionLevelLookupKeyNamePrefix = @"level-seed-";

NSString * const kUPTHDSignerErrorDomain = @"UPTHDSignerError";
NSString * const UPTHDSignerErrorCodeLevelParamNotRecognized = @"-11";
NSString * const UPTHDSignerErrorCodeLevelPrivateKeyNotFound = @"-12";
NSString * const UPTHDSignerErrorCodeInvalidSeedWords = @"-13";
NSString * const UPTHDSignerErrorCodeLevelSigningError = @"-14";

@implementation UPTHDSigner

#pragma mark - Public methods

+ (BOOL)hasSeed {
    VALValet *addressKeystore = [UPTHDSigner ethAddressesKeystore];
    NSArray *addressKeys = [[addressKeystore allKeys] allObjects];
    BOOL hasSeed = NO;
    for ( NSString *addressKey in addressKeys ) {
        if ( [addressKey containsString:@"seed"] ) {
            hasSeed = YES;
        }
    }

    return hasSeed;
}

+ (void)showSeed:(NSString *)rootAddress prompt:(NSString *)prompt callback:(UPTHDSignerSeedPhraseResult)callback {
    UPTHDSignerProtectionLevel protectionLevel = [UPTHDSigner protectionLevelWithEthAddress:rootAddress];
    if ( protectionLevel == UPTHDSignerProtectionLevelNotRecognized ) {
        NSError *protectionLevelError = [[NSError alloc] initWithDomain:kUPTHDSignerErrorDomain code:UPTHDSignerErrorCodeLevelParamNotRecognized.integerValue userInfo:@{@"message": @"protection level not found for eth address"}];
        callback( nil, protectionLevelError);
        return;
    }

    NSData *masterEntropy = [UPTHDSigner entropyWithEthAddress:rootAddress userPromptText:prompt protectionLevel:protectionLevel];
    if (!masterEntropy) {
        NSError *protectionLevelError = [[NSError alloc] initWithDomain:@"UPTHDError" code:UPTHDSignerErrorCodeLevelPrivateKeyNotFound.integerValue userInfo:@{@"message": @"private key not found for eth address"}];
        callback( nil, protectionLevelError);
        return;
    }

    BTCMnemonic *mnemonic = [[BTCMnemonic alloc] initWithEntropy:masterEntropy password:@"" wordListType:BTCMnemonicWordListTypeEnglish];
    NSString *phrase = [mnemonic.words componentsJoinedByString:@" "];
    callback( phrase, nil );
}

+ (void)deleteSeed:(NSString *)rootEthereumAddress callback:(UPTEthSignerDeleteSeedResult)callback {
    UPTHDSignerProtectionLevel protectionLevel = [UPTHDSigner protectionLevelWithEthAddress:rootEthereumAddress];
    if ( protectionLevel != UPTHDSignerProtectionLevelNotRecognized ) {
        VALValet *privateKeystore = [UPTHDSigner privateKeystoreWithProtectionLevel:protectionLevel];
        NSString *privateKeyLookupKeyName = [UPTHDSigner entropyLookupKeyNameWithEthAddress:rootEthereumAddress];
        [privateKeystore removeObjectForKey:privateKeyLookupKeyName];
    }
    
    VALValet *protectionLevelsKeystore = [UPTHDSigner keystoreForProtectionLevels];
    NSString *protectionLevelLookupKey = [UPTHDSigner protectionLevelLookupKeyNameWithEthAddress:rootEthereumAddress];
    [protectionLevelsKeystore removeObjectForKey:protectionLevelLookupKey];
    
    VALValet *addressKeystore = [UPTHDSigner ethAddressesKeystore];
    [addressKeystore removeObjectForKey:rootEthereumAddress];
    
    callback( YES, nil );
}

+ (void)createHDSeed:(UPTHDSignerProtectionLevel)protectionLevel callback:(UPTHDSignerSeedCreationResult)callback {
    [UPTHDSigner
        createHDSeed:protectionLevel
        rootDerivationPath:UPORT_ROOT_DERIVATION_PATH
        callback:callback
    ];
}
+ (void)createHDSeed:(UPTHDSignerProtectionLevel)protectionLevel
    rootDerivationPath:(NSString *)rootDerivationPath
    callback:(UPTHDSignerSeedCreationResult)callback
{
    NSData *randomEntropy = [UPTHDSigner randomEntropy];
    BTCMnemonic *mnemonic = [[BTCMnemonic alloc] initWithEntropy:randomEntropy password:@"" wordListType:BTCMnemonicWordListTypeEnglish];
    NSString *wordsString = [mnemonic.words componentsJoinedByString:@" "];
    [UPTHDSigner importSeed:protectionLevel phrase:wordsString rootDerivationPath:rootDerivationPath callback:callback];
}

+ (void)importSeed:(UPTHDSignerProtectionLevel)protectionLevel
    phrase:(NSString *)phrase
    callback:(UPTHDSignerSeedCreationResult)callback
{
    [UPTHDSigner
        importSeed:protectionLevel
        phrase:phrase
        rootDerivationPath:UPORT_ROOT_DERIVATION_PATH
        callback:callback
    ];
}
+ (void)importSeed:(UPTHDSignerProtectionLevel)protectionLevel
    phrase:(NSString *)phrase
    rootDerivationPath:(NSString *)rootDerivationPath
    callback:(UPTHDSignerSeedCreationResult)callback
{
    NSArray<NSString *> *words = [UPTHDSigner wordsFromPhrase:phrase];
    [UPTHDSigner
        importSeed:protectionLevel
        words:words
        rootDerivationPath:rootDerivationPath
        callback:callback
    ];
}
+ (void)importSeed:(UPTHDSignerProtectionLevel)protectionLevel
    words:(NSArray<NSString *> *)words
    rootDerivationPath:(NSString *)derivationPath
    callback:(UPTHDSignerSeedCreationResult)callback
{
    BTCMnemonic *mnemonic = [[BTCMnemonic alloc] initWithWords:words password:@"" wordListType:BTCMnemonicWordListTypeEnglish];
    if (!mnemonic) {
        callback(nil, nil, [[NSError alloc]
            initWithDomain:kUPTHDSignerErrorDomain
            code:UPTHDSignerErrorCodeInvalidSeedWords.integerValue
            userInfo:@{
                @"message": @"Invalid seed phrase checksum"
            }
        ]);
        return;
    }
    BTCKeychain *masterKeychain = [[BTCKeychain alloc] initWithSeed:mnemonic.seed];

    BTCKeychain *rootKeychain = [masterKeychain derivedKeychainWithPath:derivationPath];
    NSString *rootPublicKeyString = [rootKeychain.key.uncompressedPublicKey base64EncodedStringWithOptions:0];
    NSString *rootEthereumAddress = [UPTHDSigner ethereumAddressWithPublicKey:rootKeychain.key.uncompressedPublicKey];

    VALValet *privateKeystore = [UPTHDSigner privateKeystoreWithProtectionLevel:protectionLevel];
    NSString *privateKeyLookupKeyName = [UPTHDSigner entropyLookupKeyNameWithEthAddress:rootEthereumAddress];
    [privateKeystore setObject:mnemonic.entropy forKey:privateKeyLookupKeyName];
    [UPTHDSigner saveProtectionLevel:protectionLevel withEthAddress:rootEthereumAddress];
    [UPTHDSigner saveEthAddress:rootEthereumAddress];

    callback( rootEthereumAddress, rootPublicKeyString, nil );
}

+ (void)computeAddressForPath:(NSString *)rootAddress derivationPath:(NSString *)derivationPath prompt:(NSString *)prompt callback:(UPTHDSignerSeedCreationResult)callback {
    UPTHDSignerProtectionLevel protectionLevel = [UPTHDSigner protectionLevelWithEthAddress:rootAddress];
    if ( protectionLevel == UPTHDSignerProtectionLevelNotRecognized ) {
        NSError *protectionLevelError = [[NSError alloc] initWithDomain:kUPTHDSignerErrorDomain code:UPTHDSignerErrorCodeLevelParamNotRecognized.integerValue userInfo:@{@"message": @"protection level not found for eth address"}];
        callback( nil, nil, protectionLevelError);
        return;
    }

    NSData *masterEntropy = [UPTHDSigner entropyWithEthAddress:rootAddress userPromptText:prompt protectionLevel:protectionLevel];
    if (!masterEntropy) {
        NSError *protectionLevelError = [[NSError alloc] initWithDomain:@"UPTError" code:UPTHDSignerErrorCodeLevelPrivateKeyNotFound.integerValue userInfo:@{@"message": @"private key not found for eth address"}];
        callback( nil, nil, protectionLevelError);
        return;
    }

    BTCMnemonic *mnemonic = [[BTCMnemonic alloc] initWithEntropy:masterEntropy password:@"" wordListType:BTCMnemonicWordListTypeEnglish];
    BTCKeychain *masterKeychain = [[BTCKeychain alloc] initWithSeed:mnemonic.seed];

    BTCKeychain *rootKeychain = [masterKeychain derivedKeychainWithPath:derivationPath];
    NSString *rootPublicKeyString = [rootKeychain.key.uncompressedPublicKey base64EncodedStringWithOptions:0];
    NSString *rootEthereumAddress = [UPTHDSigner ethereumAddressWithPublicKey:rootKeychain.key.uncompressedPublicKey];
    callback( rootEthereumAddress, rootPublicKeyString, nil );
}

+ (void)signTransaction:(NSString *)rootAddress derivationPath:(NSString *)derivationPath txPayload:(NSString *)txPayload prompt:(NSString *)prompt callback:(UPTHDSignerTransactionSigningResult)callback {
    NSData *payloadData = [[NSData alloc] initWithBase64EncodedString:txPayload options:0];
    [UPTHDSigner
        signTransaction:rootAddress
        derivationPath:derivationPath
        serializedTxPayload:payloadData
        chainId:nil
        prompt:prompt
        callback:callback
    ];
}
+ (void)signTransaction:(NSString *)rootAddress derivationPath:(NSString *)derivationPath serializedTxPayload:(NSData *)payloadData chainId:(NSData *)chainId prompt:(NSString *)prompt callback:(UPTHDSignerTransactionSigningResult)callback {
    UPTHDSignerProtectionLevel protectionLevel = [UPTHDSigner protectionLevelWithEthAddress:rootAddress];
    if ( protectionLevel == UPTHDSignerProtectionLevelNotRecognized ) {
        NSError *protectionLevelError = [[NSError alloc] initWithDomain:kUPTHDSignerErrorDomain code:UPTHDSignerErrorCodeLevelParamNotRecognized.integerValue userInfo:@{@"message": @"protection level not found for eth address"}];
        callback( nil, protectionLevelError);
        return;
    }

    NSData *masterEntropy = [UPTHDSigner entropyWithEthAddress:rootAddress userPromptText:prompt protectionLevel:protectionLevel];
    if (!masterEntropy) {
        NSError *protectionLevelError = [[NSError alloc] initWithDomain:@"UPTError" code:UPTHDSignerErrorCodeLevelPrivateKeyNotFound.integerValue userInfo:@{@"message": @"private key not found for eth address"}];
        callback( nil, protectionLevelError);
        return;
    }

    BTCMnemonic *mnemonic = [[BTCMnemonic alloc] initWithEntropy:masterEntropy password:@"" wordListType:BTCMnemonicWordListTypeEnglish];
    BTCKeychain *masterKeychain = [[BTCKeychain alloc] initWithSeed:mnemonic.seed];
    BTCKeychain *derivedKeychain = [masterKeychain derivedKeychainWithPath:derivationPath];

    NSData *hash = [UPTHDSigner keccak256:payloadData];
    NSDictionary *signature = ethereumSignature(derivedKeychain.key, hash, chainId);
    if (signature) {
        callback(signature, nil);
    } else {
        NSError *signingError = [[NSError alloc] initWithDomain:@"UPTError"
                                                           code:UPTHDSignerErrorCodeLevelSigningError.integerValue
                                                       userInfo:@{@"message": [NSString stringWithFormat:@"signing failed due to invalid signature components for eth address: signTransaction %@", rootAddress]}];
        callback(nil, signingError);
    }
}

+ (void)signJWT:(NSString *)rootAddress derivationPath:(NSString *)derivationPath data:(NSString *)data prompt:(NSString *)prompt callback:(UPTHDSignerJWTSigningResult)callback {
    UPTHDSignerProtectionLevel protectionLevel = [UPTHDSigner protectionLevelWithEthAddress:rootAddress];
    if ( protectionLevel == UPTHDSignerProtectionLevelNotRecognized ) {
        NSError *protectionLevelError = [[NSError alloc] initWithDomain:kUPTHDSignerErrorDomain code:UPTHDSignerErrorCodeLevelParamNotRecognized.integerValue userInfo:@{@"message": @"protection level not found for eth address"}];
        callback( nil, protectionLevelError);
        return;
    }

    NSData *masterEntropy = [UPTHDSigner entropyWithEthAddress:rootAddress userPromptText:prompt protectionLevel:protectionLevel];
    if (!masterEntropy) {
        NSError *protectionLevelError = [[NSError alloc] initWithDomain:@"UPTError" code:UPTHDSignerErrorCodeLevelPrivateKeyNotFound.integerValue userInfo:@{@"message": @"private key not found for eth address"}];
        callback( nil, protectionLevelError);
        return;
    }

    BTCMnemonic *mnemonic = [[BTCMnemonic alloc] initWithEntropy:masterEntropy password:@"" wordListType:BTCMnemonicWordListTypeEnglish];
    BTCKeychain *masterKeychain = [[BTCKeychain alloc] initWithSeed:mnemonic.seed];
    BTCKeychain *derivedKeychain = [masterKeychain derivedKeychainWithPath:derivationPath];

    NSData *payloadData = [[NSData alloc] initWithBase64EncodedString:data options:0];
    NSData *hash = [payloadData SHA256];
    NSData *signature = simpleSignature(derivedKeychain.key, hash);
    if (signature) {
        NSString *base64EncodedSignature = [signature base64EncodedStringWithOptions:0];
        NSString *webSafeBase64Signature = [UPTHDSigner URLEncodedBase64StringWithBase64String:base64EncodedSignature];
        callback(webSafeBase64Signature, nil);
    } else {
        NSError *signingError = [[NSError alloc] initWithDomain:@"UPTError"
                                                           code:UPTHDSignerErrorCodeLevelSigningError.integerValue
                                                       userInfo:@{@"message": [NSString stringWithFormat:@"signing failed due to invalid signature components for eth address: signTransaction %@", rootAddress]}];
        callback(nil, signingError);
    }
}

+ (void)privateKeyForPath:(NSString *)rootAddress derivationPath:(NSString *)derivationPath prompt:(NSString *)prompt callback:(UPTHDSignerPrivateKeyResult)callback {
    UPTHDSignerProtectionLevel protectionLevel = [UPTHDSigner protectionLevelWithEthAddress:rootAddress];
    if ( protectionLevel == UPTHDSignerProtectionLevelNotRecognized ) {
        NSError *protectionLevelError = [[NSError alloc] initWithDomain:kUPTHDSignerErrorDomain code:UPTHDSignerErrorCodeLevelParamNotRecognized.integerValue userInfo:@{@"message": @"protection level not found for eth address"}];
        callback(nil, protectionLevelError);
        return;
    }

    NSData *masterEntropy = [UPTHDSigner entropyWithEthAddress:rootAddress userPromptText:prompt protectionLevel:protectionLevel];
    if (!masterEntropy) {
        NSError *protectionLevelError = [[NSError alloc] initWithDomain:@"UPTError" code:UPTHDSignerErrorCodeLevelPrivateKeyNotFound.integerValue userInfo:@{@"message": @"private key not found for eth address"}];
        callback(nil, protectionLevelError);
        return;
    }

    BTCMnemonic *mnemonic = [[BTCMnemonic alloc] initWithEntropy:masterEntropy password:@"" wordListType:BTCMnemonicWordListTypeEnglish];
    BTCKeychain *masterKeychain = [[BTCKeychain alloc] initWithSeed:mnemonic.seed];
    BTCKeychain *derivedKeychain = [masterKeychain derivedKeychainWithPath:derivationPath];

    NSString *derivedPrivateKeyBase64 = [derivedKeychain.key.privateKey base64EncodedStringWithOptions:0];
    callback(derivedPrivateKeyBase64, nil);
}


#pragma mark - Private methods

+ (NSString *)ethereumAddressWithPublicKey:(NSData *)publicKey {
    NSData *strippedPublicKey = [publicKey subdataWithRange:NSMakeRange(1,[publicKey length]-1)];
    NSData *address = [[UPTHDSigner keccak256:strippedPublicKey] subdataWithRange:NSMakeRange(12, 20)];
    return [NSString stringWithFormat:@"0x%@", [address hex]];
}

+ (NSData *)keccak256:(NSData *)input {
    char *outputBytes = malloc(32);
    sha3_256((unsigned char *)outputBytes, 32, (unsigned char *)[input bytes], (unsigned int)[input length]);
    return [NSData dataWithBytes:outputBytes length:32];
}

+ (UPTHDSignerProtectionLevel)protectionLevelWithEthAddress:(NSString *)ethAddress {
    NSString *protectionLevelLookupKeyName = [UPTHDSigner protectionLevelLookupKeyNameWithEthAddress:ethAddress];
    VALValet *protectionLevelsKeystore = [UPTHDSigner keystoreForProtectionLevels];
    NSString *keychainSourcedProtectionLevel = [protectionLevelsKeystore stringForKey:protectionLevelLookupKeyName];
    if (!keychainSourcedProtectionLevel ) {
        return UPTHDSignerProtectionLevelNotRecognized;
    }
    return [UPTHDSigner protectionLevelFromKeychainSourcedProtectionLevel:keychainSourcedProtectionLevel];
}

/// @param protectionLevel sourced from the keychain. Was originally created with +(NSString *)keychainCompatibleProtectionLevel:
+ (UPTHDSignerProtectionLevel)protectionLevelFromKeychainSourcedProtectionLevel:(NSString *)protectionLevel {
    return (UPTHDSignerProtectionLevel)protectionLevel.integerValue;
}

/// @param protectionLevel indicates which private keystore to create and return
/// @return returns VALValet or valid subclass: VALSynchronizableValet, VALSecureEnclaveValet, VALSinglePromptSecureEnclaveValet
+ (VALValet *)privateKeystoreWithProtectionLevel:(UPTHDSignerProtectionLevel)protectionLevel {
    VALValet *keystore;
    switch ( protectionLevel ) {
        case UPTHDSignerProtectionLevelNormal: {
            keystore = [[VALValet alloc] initWithIdentifier:UPTHDPrivateKeyIdentifier accessibility:VALAccessibilityWhenUnlockedThisDeviceOnly];
            break;
        }
        case UPTHDSignerProtectionLevelICloud: {
            keystore = [[VALSynchronizableValet alloc] initWithIdentifier:UPTHDPrivateKeyIdentifier accessibility:VALAccessibilityWhenUnlocked];
            break;
        }
        case UPTHDSignerProtectionLevelPromptSecureEnclave: {
            keystore = [[VALSecureEnclaveValet alloc] initWithIdentifier:UPTHDPrivateKeyIdentifier accessControl:VALAccessControlUserPresence];
            break;
        }
        case UPTHDSignerProtectionLevelSinglePromptSecureEnclave: {
            keystore = [[VALSinglePromptSecureEnclaveValet alloc] initWithIdentifier:UPTHDPrivateKeyIdentifier accessControl:VALAccessControlUserPresence];
            break;
        }
        case UPTHDSignerProtectionLevelNotRecognized: {
            keystore = nil;
            break;
        }
        default: {
            keystore = nil;
            break;
        }
    }

    return keystore;
}


+ (void)saveProtectionLevel:(UPTHDSignerProtectionLevel)protectionLevel withEthAddress:(NSString *)ethAddress {
    VALValet *protectionLevelsKeystore = [UPTHDSigner keystoreForProtectionLevels];
    NSString *protectionLevelLookupKey = [UPTHDSigner protectionLevelLookupKeyNameWithEthAddress:ethAddress];
    NSString *keystoreCompatibleProtectionLevel = [UPTHDSigner keychainCompatibleProtectionLevel:protectionLevel];
    [protectionLevelsKeystore setString:keystoreCompatibleProtectionLevel forKey:protectionLevelLookupKey];
}

+ (VALValet *)keystoreForProtectionLevels {
    return [[VALValet alloc] initWithIdentifier:UPTHDProtectionLevelIdentifier accessibility:VALAccessibilityAlways];
}

+ (NSString *)entropyLookupKeyNameWithEthAddress:(NSString *)ethAddress {
    return [NSString stringWithFormat:@"%@%@", UPTHDEntropyLookupKeyNamePrefix, ethAddress];
}

+ (NSString *)protectionLevelLookupKeyNameWithEthAddress:(NSString *)ethAddress {
    return [NSString stringWithFormat:@"%@%@", UPTHDEntropyProtectionLevelLookupKeyNamePrefix, ethAddress];
}

+ (VALValet *)ethAddressesKeystore {
    return [[VALValet alloc] initWithIdentifier:UPTHDAddressIdentifier accessibility:VALAccessibilityAlways];
}

/// @return NSString a derived version of UPTEthKeychainProtectionLevel appropriate for keychain storage
+ (NSString *)keychainCompatibleProtectionLevel:(UPTHDSignerProtectionLevel)protectionLevel {
    return @(protectionLevel).stringValue;
}

+ (void)saveEthAddress:(NSString *)ethAddress {
    VALValet *addressKeystore = [UPTHDSigner ethAddressesKeystore];
    [addressKeystore setString:ethAddress forKey:ethAddress];
}

/// @param userPromptText the string to display to the user when requesting access to the secure enclave
/// @return private key as NSData
+ (NSData *)entropyWithEthAddress:(NSString *)ethAddress userPromptText:(NSString *)userPromptText protectionLevel:(UPTHDSignerProtectionLevel)protectionLevel {
    VALValet *entropyKeystore = [self privateKeystoreWithProtectionLevel:protectionLevel];
    NSString *entropyLookupKeyName = [UPTHDSigner entropyLookupKeyNameWithEthAddress:ethAddress];
    NSData *entropy;
    switch ( protectionLevel ) {
        case UPTHDSignerProtectionLevelNormal: {
            entropy = [entropyKeystore objectForKey:entropyLookupKeyName];
            break;
        }
        case UPTHDSignerProtectionLevelICloud: {
            entropy = [entropyKeystore objectForKey:entropyLookupKeyName];
            break;
        }
        case UPTHDSignerProtectionLevelPromptSecureEnclave: {
            entropy = [(VALSecureEnclaveValet *)entropyKeystore objectForKey:entropyLookupKeyName userPrompt:userPromptText userCancelled:nil];
            break;
        }
        case UPTHDSignerProtectionLevelSinglePromptSecureEnclave: {
            entropy = [(VALSinglePromptSecureEnclaveValet *)entropyKeystore objectForKey:entropyLookupKeyName userPrompt:userPromptText userCancelled:nil];
            break;
        }
        case UPTHDSignerProtectionLevelNotRecognized: {
            entropy = nil;
            break;
        }
        default: {
            entropy = nil;
            break;
        }
    }

    return entropy;
}


+ (NSMutableData*) compressedPublicKey:(EC_KEY *)key {
    if (!key) return nil;
    EC_KEY_set_conv_form(key, POINT_CONVERSION_COMPRESSED);//POINT_CONVERSION_UNCOMPRESSED //POINT_CONVERSION_COMPRESSED
    int length = i2o_ECPublicKey(key, NULL);
    if (!length) return nil;
    NSAssert(length <= 65, @"Pubkey length must be up to 65 bytes.");
    NSMutableData* data = [[NSMutableData alloc] initWithLength:length];
    unsigned char* bytes = [data mutableBytes];
    if (i2o_ECPublicKey(key, &bytes) != length) return nil;
    return data;
}

#pragma mark - Utils

+ (NSArray<NSString *> *)wordsFromPhrase:(NSString *)phrase {
    NSArray<NSString *> *words = [phrase componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    return [words filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF != ''"]];
}

+ (NSData*)randomEntropy {
    NSUInteger entropyCapacity = 128 / 8;
    NSMutableData* entropy = [NSMutableData dataWithCapacity:(128 / 8)];
    NSUInteger numBytes = entropyCapacity / 4;
    for( NSUInteger i = 0 ; i < numBytes; ++i ) {
        u_int32_t randomBits = arc4random();
        [entropy appendBytes:(void *)&randomBits length:4];
    }

    return entropy;
}

+ (UPTHDSignerProtectionLevel)enumStorageLevelWithStorageLevel:(NSString *)storageLevel {
    NSArray<NSString *> *storageLevels = @[ ReactNativeHDSignerProtectionLevelNormal,
            ReactNativeHDSignerProtectionLevelICloud,
            ReactNativeHDSignerProtectionLevelPromptSecureEnclave,
            ReactNativeHDSignerProtectionLevelSinglePromptSecureEnclave];
    return (UPTHDSignerProtectionLevel)[storageLevels indexOfObject:storageLevel];
}

+ (NSString *)base64StringWithURLEncodedBase64String:(NSString *)URLEncodedBase64String {
    NSMutableString *characterConverted = [[[URLEncodedBase64String stringByReplacingOccurrencesOfString:@"-" withString:@"+"] stringByReplacingOccurrencesOfString:@"_" withString:@"/"] mutableCopy];
    if ( characterConverted.length % 4 != 0 ) {
        NSUInteger numEquals = 4 - characterConverted.length % 4;
        NSString *equalsPadding = [@"" stringByPaddingToLength:numEquals withString: @"=" startingAtIndex:0];
        [characterConverted appendString:equalsPadding];
    }

    return characterConverted;
}

+ (NSString *)URLEncodedBase64StringWithBase64String:(NSString *)base64String {
    return [[[base64String stringByReplacingOccurrencesOfString:@"+" withString:@"-"] stringByReplacingOccurrencesOfString:@"/" withString:@"_"] stringByReplacingOccurrencesOfString:@"=" withString:@""];
}

@end
