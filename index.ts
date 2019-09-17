
import { NativeModules } from 'react-native';
import { Buffer } from 'buffer';

const RNUportSigner: any = NativeModules.RNUportSignerModule;
const RNUportHDSigner: any = NativeModules.RNUportHDSignerModule;

const getSignerForHDPath = (
  seedAlias: string,
  derivationPath: string = RNUportHDSigner.UPORT_ROOT_DERIVATION_PATH,
  userPrompt = ''): object => {

  return async (data: string) => {
    const { v, r, s } = await RNUportHDSigner.signJwt(seedAlias,
      derivationPath,
      Buffer.from(data).toString('base64'),
      userPrompt);

    return {
      recoveryParam: ((v === 0 || v === 1) ? v : v - 27),
      r: Buffer.from(r, 'base64').toString('hex'),
      s: Buffer.from(s, 'base64').toString('hex')
    };
  };
};

export { RNUportSigner, RNUportHDSigner, getSignerForHDPath };
