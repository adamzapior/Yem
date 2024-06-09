//
//  AuthManager.swift
//  Yem
//
//  Created by Adam Zapiór on 27/03/2024.
//

import FirebaseAuth
import Foundation

final class AuthenticationManager {
    init() {}
    
    func loginUser(email: String, password: String) async throws -> UserModel {
        
        let user: User?
        
        do {
            let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
            // User signs in successfully
            user = authDataResult.user
//            let userEmail = user.email
//            print("User signed in successfully with email: \(userEmail ?? "Unknown")")
        } catch {
            throw error
//            let nsError = error as NSError
//            if let errorCode = AuthErrorCode.Code(rawValue: nsError.code) {
//                switch errorCode {
//                case .operationNotAllowed:
//                    // Error: The given sign-in provider is disabled for this Firebase project.
//                    break
//                case .userDisabled:
//                    // Error: The user account has been disabled by an administrator.
//                    break
//                case .wrongPassword:
//                    // Error: The password is invalid or the user does not have a password.
//                    break
//                case .userNotFound:
//                    // Error: There is no user record corresponding to this identifier. The user may have been deleted.
//                    break
//                default:
//                    print("Error: \(nsError.localizedDescription)")
//                }
//            }
        }
        guard let validUser = user else {
               throw NSError(domain: "AuthError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Nieznany błąd autoryzacji"])
           }

           return UserModel(user: validUser)
    }
    
    func createUser(email: String, password: String) async throws -> UserModel {
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        // User is created successfully
        return UserModel(user: authDataResult.user)
    }
    
    func signOut() async throws {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}
