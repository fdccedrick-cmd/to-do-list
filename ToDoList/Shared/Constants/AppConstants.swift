//
//  AppConstants.swift
//  ToDoList
//
//  Created by Cedrick Agtong - INTERN on 3/6/26.
//

import Foundation

enum AppConstants {
    // User Defaults Keys
    enum UserDefaultsKeys {
        static let todos = "saved_todos"
    }
    
    // UI Constants
    enum UI {
        static let cornerRadius: CGFloat = 12
        static let standardPadding: CGFloat = 16
        static let smallPadding: CGFloat = 8
    }
}
