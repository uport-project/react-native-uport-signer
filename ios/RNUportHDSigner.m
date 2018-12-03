
#import "RNUportHDSigner.h"
#import "UPTHDSigner.h"

@implementation RNUportHDSigner

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(hasSeed:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    resolve(@([UPTHDSigner hasSeed]));
}

RCT_EXPORT_METHOD(createSeed:(NSString *)protectionLevel resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    UPTHDSignerProtectionLevel enumStorageLevel = [UPTHDSigner enumStorageLevelWithStorageLevel:protectionLevel];
    if ( enumStorageLevel == UPTHDSignerProtectionLevelNotRecognized ) {
        reject( UPTHDSignerErrorCodeLevelParamNotRecognized, UPTHDSignerErrorCodeLevelParamNotRecognized, nil);
        return;
    }
    
    [UPTHDSigner createHDSeed:enumStorageLevel callback:^(NSString *ethAddress, NSString *publicKey, NSError *error) {
        if ( !error ) {
            resolve( @{ @"address": ethAddress, @"pubKey": publicKey } );
        } else {
            reject( @(error.code).stringValue , error.description, error );
        }
    }];
}

RCT_EXPORT_METHOD(addressForPath:(NSString *)rootAddress derivationPath:(NSString *)derivationPath prompt:(NSString *)prompt resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    [UPTHDSigner computeAddressForPath:rootAddress derivationPath:derivationPath prompt:prompt callback:^(NSString *ethAddress, NSString *publicKey, NSError *error) {
        if ( !error ) {
            resolve( @{ @"address": ethAddress, @"pubKey": publicKey } );
        } else {
            reject( @(error.code).stringValue , error.description, error );
        }
    }];
}

RCT_EXPORT_METHOD(showSeed:(NSString *)rootAddress prompt:(NSString *)prompt resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    [UPTHDSigner showSeed:rootAddress prompt:prompt callback:^(NSString *phrase, NSError *error) {
        if ( !error ) {
            resolve( phrase );
        } else {
            reject( @(error.code).stringValue , error.description, error );
        }
    }];
}

RCT_EXPORT_METHOD(importSeed:(NSString *)phrase level:(NSString *)protectionLevel resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    UPTHDSignerProtectionLevel enumStorageLevel = [UPTHDSigner enumStorageLevelWithStorageLevel:protectionLevel];
    if ( enumStorageLevel == UPTHDSignerProtectionLevelNotRecognized ) {
        reject( UPTHDSignerErrorCodeLevelParamNotRecognized, UPTHDSignerErrorCodeLevelParamNotRecognized, nil);
        return;
    }
    
    [UPTHDSigner importSeed:enumStorageLevel phrase:phrase callback:^(NSString *ethAddress, NSString *publicKey, NSError *error) {
        if ( !error ) {
            resolve( @{ @"address": ethAddress, @"pubKey": publicKey } );
        } else {
            reject( @(error.code).stringValue , error.description, error );
        }
    }];
}

RCT_EXPORT_METHOD(signTx:(NSString *)rootAddress derivationPath:(NSString *)derivationPath txPayload:(NSString *)txPayload prompt:(NSString *)prompt resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    [UPTHDSigner signTransaction:rootAddress derivationPath:derivationPath txPayload:txPayload prompt:prompt callback:^(NSDictionary *signature, NSError *error) {
        if ( !error ) {
            resolve( signature );
        } else {
            reject( @(error.code).stringValue , error.description, error );
        }
    }];
}

RCT_EXPORT_METHOD(signJwt:(NSString *)rootAddress derivationPath:(NSString *)derivationPath data:(NSString *)data prompt:(NSString *)prompt resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    [UPTHDSigner signJWT:rootAddress derivationPath:derivationPath data:data prompt:prompt callback:^(NSString *signature, NSError *error) {
        if ( !error ) {
            resolve(signature);
        } else {
            reject( @(error.code).stringValue , error.description, error );
        }
    }];
}

RCT_EXPORT_METHOD(privateKeyForPath:(NSString *)rootAddress derivationPath:(NSString *)derivationPath prompt:(NSString *)prompt resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    [UPTHDSigner privateKeyForPath:rootAddress derivationPath:derivationPath prompt:prompt callback:^(NSString *privateKeyBase64, NSError *error) {
        if ( !error ) {
            resolve( privateKeyBase64 );
        } else {
            reject( @(error.code).stringValue , error.description, error );
        }
    }];
}

RCT_EXPORT_METHOD(deleteSeed:(NSString *)phrase resolve:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    [UPTHDSigner deleteSeed:phrase callback:^(BOOL deleted, NSError *error) {
        if ( !error ) {
            //            resolve( [NSNumber numberWithBool:deleted] );
            resolve( nil );
        } else {
            NSString *errorCode = [NSString stringWithFormat:@"%@", @(error.code)];
            reject( errorCode, error.description, error);
        }
    }];
}


@end
  
