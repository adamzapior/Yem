//
//  UserModel.swift
//  Yem
//
//  Created by Adam Zapiór on 02/04/2024.
//

import Foundation
import FirebaseAuth

struct UserModel {
    let uid: String
    let email: String?
    
    init(user: User) {
        self.uid = user.uid
        self.email = user.email
    }
}
