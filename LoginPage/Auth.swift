//
//  Auth.swift
//  LoginPage
//
//  Created by Роберт Хайреев on 25/07/2017.
//  Copyright © 2017 Robert Khayreev. All rights reserved.
//

import Foundation
import RxSwift

enum LoginError: Error {
  case invalidCredentials
  case connectionError
}

enum UserState {
  case loggedIn(user: String)
  case loggedOut
  case error(LoginError)
}

class Auth {
  let userState = Variable(UserState.loggedOut)
  
  static var shared = Auth()
  
  func logIn(email: String, password: String) {
    guard isEmailValid(email) && isPasswordValid(password) else {
      userState.value = .error(.invalidCredentials)
      return
    }
    userState.value = .loggedIn(user: "email: \(email)")
  }
  
  func logOut() {
    userState.value = .loggedOut
  }
  
  // validation
  func isPasswordValid(_ password: String) -> Bool {
    let capitalLetterRegEx = ".*[A-Z]+.*"
    let lowercaseLetterRegEx = ".*[a-z]+.*"
    let numberRegEx = ".*[0-9]+.*"
    let format = "SELF MATCHES %@"
    
    let isLengthValid = password.characters.count >= 6
    let containsCapitalLetter = NSPredicate(format: format, capitalLetterRegEx).evaluate(with: password)
    let containsLowercaseLetter = NSPredicate(format: format, lowercaseLetterRegEx).evaluate(with: password)
    let containsNumber = NSPredicate(format: format, numberRegEx).evaluate(with: password)
    
    return isLengthValid && containsCapitalLetter && containsLowercaseLetter && containsNumber
  }
  
  func isEmailValid(_ email: String) -> Bool {
    let emailRegEx = "[A-Z0-9a-z._-]+@[A-Za-z0-9-]+\\.[A-Za-z]{2,}"
    return NSPredicate(format: "SELF MATCHES %@", emailRegEx).evaluate(with: email)
  }
  
}
