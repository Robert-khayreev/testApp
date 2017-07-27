//
//  LoginViewController.swift
//  LoginPage
//
//  Created by Роберт Хайреев on 25/07/2017.
//  Copyright © 2017 Robert Khayreev. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Alamofire

class LoginViewController: UIViewController {

  
  
  @IBOutlet weak var yCenterConstraint: NSLayoutConstraint!
  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  @IBOutlet weak var forgotPasswordButton: UIButton!
  @IBOutlet weak var loginButton: UIButton!
  
  let bag = DisposeBag()
  let auth = Auth.shared
  
  override func viewDidLoad() {
    super.viewDidLoad()
    forgotPasswordButton.layer.borderColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 235/255).cgColor
    subscribeToUserStateEvents()
    subscribeToTapEvents()
    subscribeToKeyboardEvents()
  }
  
  func subscribeToKeyboardEvents() {
    keyboardHeight().observeOn(MainScheduler.instance)
      .subscribe(
        onNext: { [weak self] height in
          
          UIView.animate(withDuration: 0.3,
                         delay: 0,
                         options: .curveEaseOut,
                         animations: {
                          self?.yCenterConstraint.constant = -height/2
                          self?.view.layoutIfNeeded()
                          
          })
          
      }).addDisposableTo(bag)
  }

  func subscribeToTapEvents() {
    
    let tapGestureRecognizer = UITapGestureRecognizer()
    view.addGestureRecognizer(tapGestureRecognizer)
    tapGestureRecognizer.rx.event.asObservable()
      .subscribe(onNext: { [weak self] _ in self?.hideKeyboard() }).addDisposableTo(bag)
    
    loginButton.rx.tap.subscribe(onNext: { [weak self] _ in
      guard let email = self?.emailTextField.text, let password = self?.passwordTextField.text else { return }
      self?.auth.logIn(email: email, password: password)
    }).addDisposableTo(bag)
  }
  
  func subscribeToUserStateEvents() {
    auth.userState.asObservable().subscribe(
      
      onNext: { [weak self] state in
        switch state {
          
        case .loggedIn(let user):
          print("logged in as: ", user)
          self?.checkWeather() { [weak self] dict in
            
            guard let city = dict["city"] as? String,
                  let temp = dict["temp"] as? Double else {return}
            
            let celcius = round(temp - 273.15)
            let stringToShow = "The temprature in \(city) is \(celcius)"
            self?.showAlert(title: "Weather",
                            message: stringToShow,
                            okAction: { self?.auth.logOut() })
            
          }
        case .loggedOut:
          print("logged out")
        case .error(let error):
          self?.showAlert(title: "Error", message: "\(error)", okAction: nil)
          self?.auth.userState.value = .loggedOut
        }
        
      }
    ).addDisposableTo(bag)
  }
  
  func hideKeyboard() {
    emailTextField.resignFirstResponder()
    passwordTextField.resignFirstResponder()
  }
  
  func checkWeather(onSuccess: @escaping ([String: Any?]) -> Void) {
    Alamofire.request("http://api.openweathermap.org/data/2.5/weather?q=Moscow,ru&appid=b60b3bdc3cbe5a6a319cd7729bb2290b",
                      method: .get,
                      parameters: nil,
                      encoding: URLEncoding.default,
                      headers: nil).responseJSON { jsonData in
                        guard let dict = jsonData.value as? [String: Any],
                              let main = dict["main"] as? [String: Any],
                              dict["cod"] as? Int == 200  else {return}
                        
                        DispatchQueue.main.async {
                          onSuccess(["city": dict["name"],
                                     "temp": main["temp"]])
                        }
    }
  }
}

extension LoginViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField === emailTextField {
      passwordTextField.becomeFirstResponder()
    } else if textField === passwordTextField {
      textField.resignFirstResponder()
    }
    return true
  }
}
