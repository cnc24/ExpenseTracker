//
//  UserViewModel.swift
//  ExpenseTracker
//
//  Created by Jeremias Esser on 19.07.24.
//

import Foundation
import Combine

class UserViewModel: ObservableObject {
    @Published var isProUser: Bool
    
    init(isProUser: Bool = false) {
        self.isProUser = isProUser
    }
}
