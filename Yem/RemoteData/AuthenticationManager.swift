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
        } catch {
            let error = error as NSError
            let authError = error.getError()

            throw authError
        }

        guard let validUser = user else {
            throw AuthError.unknownError
        }

        return UserModel(user: validUser)
    }

    func createUser(email: String, password: String) async throws -> UserModel {
        let user: User?
        do {
            let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
            // User is created successfully
            user = authDataResult.user
        } catch {
            let error = error as NSError
            let authError = error.getError()

            throw authError
        }

        guard let createdUser = user else {
            throw AuthError.unknownError
        }

        return UserModel(user: createdUser)
    }

    func signOut() async throws {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}

enum AuthError: Error {
    case invalidEmail
    case invalidCredential
    case wrongPassword
    case networkError
    case weakPassword
    case emailAlreadyInUse
    case userNotFound
    case userDisabled
    case operationNotAllowed
    case tooManyRequests
    case unknownError
}

extension AuthError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return "The email address is not valid. Please enter a valid email address."
        case .invalidCredential:
            return "The credentials provided are incorrect. Please check your email and password and try again."
        case .wrongPassword:
            return "The password entered is incorrect. Please try again."
        case .networkError:
            return "There was a network error. Please check your internet connection and try again."
        case .weakPassword:
            return "The password is too weak. Please choose a stronger password."
        case .emailAlreadyInUse:
            return "The email address is already in use by another account. Please use a different email address."
        case .userNotFound:
            return "No user found with this email address. Please check and try again."
        case .userDisabled:
            return "This user account has been disabled. Please contact support for assistance."
        case .operationNotAllowed:
            return "This operation is not allowed. Please contact support for more information."
        case .tooManyRequests:
            return "You have made too many requests in a short period. Please wait and try again later."
        case .unknownError:
            return "An unknown error occurred. Please try again."
        }
    }
}

extension NSError {
    func getError() -> AuthError {
        let code = AuthErrorCode.Code(rawValue: self.code)

        switch code {
        case .invalidEmail:
            return .invalidEmail
        case .invalidCredential:
            return .invalidCredential
        case .wrongPassword:
            return .wrongPassword
        case .networkError:
            return .networkError
        case .weakPassword:
            return .weakPassword
        case .emailAlreadyInUse:
            return .emailAlreadyInUse
        case .userNotFound:
            return .userNotFound
        case .userDisabled:
            return .userDisabled
        case .operationNotAllowed:
            return .operationNotAllowed
        case .tooManyRequests:
            return .tooManyRequests
        default:
            return .unknownError
        }
    }
}
