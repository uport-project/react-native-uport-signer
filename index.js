
import { NativeModules } from 'react-native';
import { Buffer } from 'buffer';

const RNUportSigner = NativeModules.RNUportSignerModule;
const RNUportHDSigner = NativeModules.RNUportHDSignerModule;
const DerivationPathRoot = RNUportHDSigner.UPORT_ROOT_DERIVATION_PATH;

function getSignerForAddress(address, derivationPath = DerivationPathRoot, userPrompt = "") {
  return async (data) => {
    const { v, r, s } = await RNUportHDSigner.signJwt(address,
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

function constructPath(hdIndex = 0, acctIndex = 0, recovery = 0) {
  return `m/7696500'/${hdIndex}'/${acctIndex}'/${recovery}'`
}



export { RNUportSigner, RNUportHDSigner, getSignerForAddress, constructPath };
