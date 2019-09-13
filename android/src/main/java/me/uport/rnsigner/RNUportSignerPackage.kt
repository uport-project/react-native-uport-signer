@file:Suppress("unused")

package me.uport.rnsigner

import com.facebook.react.ReactPackage
import com.facebook.react.bridge.JavaScriptModule
import com.facebook.react.bridge.NativeModule
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.uimanager.ViewManager
import java.util.*

/**
 * package class as required by react native integration.
 *
 * This adds abilities to create, import and use private keys for signing,
 * either directly or by derivation from
 * seed phrases and a Hierarchically Deterministic algorithm.
 *
 * See [BIP32](https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki).
 */
class RNUportSignerPackage : ReactPackage {

    override fun createNativeModules(reactContext: ReactApplicationContext): List<NativeModule> {
        val modules = ArrayList<NativeModule>()

        modules.add(RNUportSignerModule(reactContext))
        modules.add(RNUportHDSignerModule(reactContext))
        return modules
    }

    override fun createViewManagers(reactContext: ReactApplicationContext): List<ViewManager<*, *>> {
        return emptyList()
    }

    override fun createJSModules(): MutableList<Class<out JavaScriptModule>> {
        return emptyList<Class<JavaScriptModule>>().toMutableList()
    }
}
