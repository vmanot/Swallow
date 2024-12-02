//
// Copyright (c) Vatsal Manot
//

import Foundation
#if os(macOS)
import Security
#endif

/// A utility type that provides functions to check for app sandboxing.
public struct _AppSandboxManager {
    
}

#if os(macOS)
extension _AppSandboxManager {
    //https://forums.developer.apple.com/message/135465#135465
    public static var isAppSandboxed: Bool {
        var err: OSStatus
        var me: SecCode?
        var dynamicInfo: CFDictionary?
        let defaultFlags = SecCSFlags(rawValue: 0)
        
        err = SecCodeCopySelf(defaultFlags, &me)
        
        guard me != nil else {
            return false
        }
        
        var staticMe: SecStaticCode?
        err =  SecCodeCopyStaticCode(me!, defaultFlags, &staticMe)
        
        guard staticMe != nil else {
            return false
        }
        
        err = SecCodeCopySigningInformation(staticMe!, SecCSFlags(rawValue: kSecCSDynamicInformation), &dynamicInfo)
        assert(err == errSecSuccess)
        
        if
            let info = dynamicInfo as? [String: Any],
            let entitlementsDict = info["entitlements-dict"] as? [String: Any],
            let value = entitlementsDict["com.apple.security.app-sandbox"] as? Bool
        {
            return value
        }
        
        return false
    }
    
    public static var _userHomePath: String {
        get throws {
            guard let userHomePath = getpwuid(getuid()).pointee.pw_dir else {
                throw Never.Reason.unexpected
            }
            
            let result: String = FileManager.default.string(
                withFileSystemRepresentation: userHomePath,
                length: Int(strlen(userHomePath))
            )
            
            return result
        }
    }
}
#else
extension _AppSandboxManager {
    //https://forums.developer.apple.com/message/135465#135465
    public static var isAppSandboxed: Bool {
        true
    }
}
#endif
