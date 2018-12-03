//
//  UPTEthSigner.h
//  uPortMobile
//
//  Created by josh on 10/18/17.
//  Copyright © 2017 ConsenSys AG. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "UPTProtectionLevel.h"

///
///
/// @description level param is not recognized by the system
/// @debugStrategy add support for new level value or fix possible typo or incompatibility error on react native js side
FOUNDATION_EXPORT NSString * const UPTSignerErrorCodeLevelParamNotRecognized;
FOUNDATION_EXPORT NSString * const UPTSignerErrorCodeLevelPrivateKeyNotFound;
FOUNDATION_EXPORT NSString * const UPTSignerErrorCodeLevelSigningError;

/// @param ethAddress    an Ethereum adderss with prefix '0x'. May be nil if error occured
/// @param publicKey    a base 64 encoded representation of the NSData public key. Note: encoded with no line
///                     breaks. May be nil if error occured.
/// @param error        non-nil only if an error occured
typedef void (^UPTEthSignerKeyPairCreationResult)(NSString *ethAddress, NSString *publicKey, NSError *error);

typedef void (^UPTEthSignerTransactionSigningResult)(NSDictionary *signature, NSError *error);
typedef void (^UPTEthSignerJWTSigningResult)(NSData *signature, NSError *error);
typedef void (^UPTEthSignerDeleteKeyResult)(BOOL deleted, NSError *error);

@class VALValet;

@interface UPTEthereumSigner : NSObject

+ (void)createKeyPairWithStorageLevel:(UPTEthKeychainProtectionLevel)protectionLevel result:(UPTEthSignerKeyPairCreationResult)result;

+ (void)saveKey:(NSData *)privateKey protectionLevel:(UPTEthKeychainProtectionLevel)protectionLevel result:(UPTEthSignerKeyPairCreationResult)result;

// if you are supplying chainID, your tx payload contains 9 fields; otherwise it contains 6
+ (void)signTransaction:(NSString *)ethAddress data:(NSString *)payload userPrompt:(NSString*)userPromptText result:(UPTEthSignerTransactionSigningResult)result __attribute__((deprecated));
+ (void)signTransaction:(NSString *)ethAddress serializedTxPayload:(NSData *)serializedTxPayload chainId:(NSData *)chainId userPrompt:(NSString*)userPromptText result:(UPTEthSignerTransactionSigningResult)result;

+ (void)signJwt:(NSString *)ethAddress userPrompt:(NSString*)userPromptText data:(NSData *)payload result:(UPTEthSignerJWTSigningResult)result;

+ (NSString *)ethAddressWithPublicKey:(NSData *)publicKey;
+ (void)deleteKey:(NSString *)ethAddress result:(UPTEthSignerDeleteKeyResult)result;
+ (NSArray *)allAddresses;

// utils

+ (UPTEthKeychainProtectionLevel)enumStorageLevelWithStorageLevel:(NSString *)storageLevel;

+ (NSData *)keccak256:(NSData *)input;

+ (NSString *)hexStringWithDataKey:(NSData *)dataPrivateKey;

+ (NSData *)dataFromHexString:(NSString *)originalHexString;

+ (NSString *)base64StringWithURLEncodedBase64String:(NSString *)URLEncodedBase64String;

+ (NSString *)URLEncodedBase64StringWithBase64String:(NSString *)base64String;

@end
