//
//  SupportingMethods.swift
//  LoginPage
//
//  Created by Роберт Хайреев on 26/07/2017.
//  Copyright © 2017 Robert Khayreev. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

func keyboardHeight() -> Observable<CGFloat> {
  let shownKeyboardHeight = NotificationCenter.default.rx
    .notification(NSNotification.Name.UIKeyboardWillShow)
    .map { notification -> CGFloat in
      (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.height ?? 0
  }
  
  let hiddenKeyboardHeight = NotificationCenter.default.rx
    .notification(NSNotification.Name.UIKeyboardWillHide)
    .map { _ -> CGFloat in 0 }
  
  return Observable.from([shownKeyboardHeight, hiddenKeyboardHeight]).merge()
}

extension UIViewController {
  func showAlert(title: String, message: String, okAction: (() -> Void)?) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let okAction = UIAlertAction(title: "OK!", style: .default) { _ in
      if let okAction = okAction {
        okAction()
      }
    }
    alert.addAction(okAction)
    present(alert, animated: true)
    
  }
}
