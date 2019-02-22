@import Foundation;

#import "CoreBitcoin/BTCKey.h"

NSDictionary *ethereumSignature(BTCKey *keypair, NSData *hash, NSData *chainId);
NSDictionary *jwtSignature(BTCKey *keypair, NSData *hash);
NSDictionary *genericSignature(BTCKey *keypair, NSData *hash, BOOL lowS);
NSData *simpleSignature(BTCKey *keypair, NSData *hash);
