
import { NativeModules } from 'react-native';
import { Buffer } from 'buffer';

const RNUportSigner = NativeModules.RNUportSignerModule;
const RNUportHDSigner = NativeModules.RNUportHDSignerModule;

function getSignerForHDPath(seedAlias, derivationPath = RNUportHDSigner.UPORT_ROOT_DERIVATION_PATH, userPrompt = "") {
  return async (data) => {
    const { v, r, s } = await RNUportHDSigner.signJwt(seedAlias,
      derivationPath,
      Buffer.from(data).toString('base64'),
      userPrompt);
    
    return {
      recoveryParam: ((v == 0 || v == 1) ? v : v - 27),
      r: Buffer.from(r, 'base64').toString('hex'),
      s: Buffer.from(s, 'base64').toString('hex')
    }
  }
}

export { RNUportSigner, RNUportHDSigner, getSignerForHDPath };
