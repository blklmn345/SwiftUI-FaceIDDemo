//
//  AuthHelper.swift
//  SwiftUI-FaceIDDemo
//
//  Created by H Chan on 2020/10/20.
//

import SwiftUI
import LocalAuthentication

class AuthHelper {
    
    @EnvironmentObject var authResultRepository: AuthRepository
    
    func login(using fallbackWithPasscode: Bool) {
        let context = LAContext()
        var error: NSError?
        
        let policy: LAPolicy = fallbackWithPasscode ? .deviceOwnerAuthentication : .deviceOwnerAuthenticationWithBiometrics
        
        if context.canEvaluatePolicy(policy, error: &error) {
            let reason = "Reason for using FaceID"
            context.evaluatePolicy(policy, localizedReason: reason) { (success, error) in
                if success {
                    self.authResultRepository.results.append("Success")
                    return
                }
                if let error = error as? LAError {
                    self.authResultRepository.results.append(error.localizedDescription)
                }
                
                context.invalidate()
            }
        }
    }
}
