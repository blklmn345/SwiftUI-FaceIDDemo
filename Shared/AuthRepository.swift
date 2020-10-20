//
//  AuthRepository.swift
//  SwiftUI-FaceIDDemo
//
//  Created by H Chan on 2020/10/20.
//

import Combine
import LocalAuthentication

class AuthRepository: ObservableObject {
    @Published var results: [String] = []
    @Published var showDialog = false
    @Published var dialogMessage = ""

    func login(fallbackWithPasscode: Bool, checkBeforeExecute: Bool) {
        var context = LAContext()
        var error: NSError?
        let policy: LAPolicy = fallbackWithPasscode ? .deviceOwnerAuthentication : .deviceOwnerAuthenticationWithBiometrics
        
        guard checkBeforeExecute else {
            execute(context: &context, policy: policy)
            return
        }
        
        if context.canEvaluatePolicy(policy, error: &error) {
            execute(context: &context, policy: policy)
        } else {
            showDialog(title: error?.localizedDescription ?? "LAContext.canEvaluatePolicy(_ policy: LAPolicy, error: NSErrorPointer) returned false")
        }
    }
    
    func resetBiometry() {
        let context = LAContext()
        let policy: LAPolicy = .deviceOwnerAuthentication
        
        context.evaluatePolicy(policy, localizedReason: "Reason For FaceID") { (success, error) in
            if success {
                DispatchQueue.main.async {
                    self.results.append("Success")
                }
                return
            }
            
            if let error = error as? LAError {
                var reason = ""
                self.reasonFromErrorCode(error, &reason)
                
                DispatchQueue.main.async {
                    self.results.append(reason)
                    if error.code == .userFallback {
                        self.dialogMessage = "LAError.code == .userFallback"
                        self.showDialog.toggle()
                    }
                }
            }
            
        }
    }
    
    func clearHistory() {
        self.results.removeAll()
    }
}

extension AuthRepository {
    private func reasonFromErrorCode(_ error: LAError, _ reason: inout String) {
        switch error.code {
        case .appCancel:
            reason = "appCancel"
        case .systemCancel:
            reason = "systemCancel"
        case .userCancel:
            reason = "userCancel"
        case .biometryLockout:
            reason = "biometryLockout"
        case .biometryNotAvailable:
            reason = "biometryNotAvailable"
        case .biometryNotEnrolled:
            reason = "biometryNotEnrolled"
        case .touchIDLockout:
            reason = "touchIDLockout"
        case .touchIDNotAvailable:
            reason = "touchIDNotAvailble"
        case .touchIDNotEnrolled:
            reason = "touchIDNotEnrolled"
        case .authenticationFailed:
            reason = "authenticationFailed"
        case .invalidContext:
            reason = "invalidContext"
        case .notInteractive:
            reason = "notInteractive"
        case .passcodeNotSet:
            reason = "passcodeNotSet"
        case .userFallback:
            reason = "userFallback"
        default:
            reason = "Other Errors"
        }
    }
    
    private func execute(context: inout LAContext, policy: LAPolicy) {
        let reason = "Reason for using FaceID"
        
        context.evaluatePolicy(policy, localizedReason: reason) { (success, error) in
            if success {
                DispatchQueue.main.async {
                    self.results.append("Success")
                }
                return
            }
            if let error = error as? LAError {
                var reason = ""
                
                self.reasonFromErrorCode(error, &reason)
                
                DispatchQueue.main.async {
                    self.results.append(reason)
                }
            }
        }
    }
    
    private func showDialog(title: String) {
        DispatchQueue.main.async {
            self.dialogMessage = title
            self.showDialog.toggle()
        }
    }
}

