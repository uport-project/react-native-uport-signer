using ReactNative.Bridge;
using System;
using System.Collections.Generic;
using Windows.ApplicationModel.Core;
using Windows.UI.Core;

namespace Uport.Signer.RNUportSigner
{
    /// <summary>
    /// A module that allows JS to share data.
    /// </summary>
    class RNUportSignerModule : NativeModuleBase
    {
        /// <summary>
        /// Instantiates the <see cref="RNUportSignerModule"/>.
        /// </summary>
        internal RNUportSignerModule()
        {

        }

        /// <summary>
        /// The name of the native module.
        /// </summary>
        public override string Name
        {
            get
            {
                return "RNUportSigner";
            }
        }
    }
}
