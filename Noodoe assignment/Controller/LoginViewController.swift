//
//  LoginViewController.swift
//  Noodoe assignment
//
//  Created by Gary Shih on 2021/8/3.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextfield: UITextField!
    
    @IBOutlet weak var passwordTextfield: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var loadBGView: UIView!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    var apiManager = APIManager()
    var objectID: String?
    var stoken: String?
    
    let net = NetworkStatus.shared
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        apiManager.delegate = self
        loginButton.layer.cornerRadius = loginButton.frame.height / 2
        
        //test only
        
//        emailTextfield.text = "test2@qq.com"
//        passwordTextfield.text = "test1234qq"
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
        
        toggleLoading(enable: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    
    // MARK: - Action
    
    @IBAction func loginPressed(_ sender: UIButton) {
        var errMsg = ""
        
        // check newwork connect
        
        if net.isOn {
            if let email = emailTextfield.text, let password = passwordTextfield.text {
                apiManager.login(userName: email, password: password)
                toggleLoading(enable: true)
                
            } else {
                errMsg = "Please check input info"
                
            }
        } else {
            errMsg = "Please check network connect"
        }
        
        if errMsg.count > 0 {
            let controller = UIAlertController(title: "Warning!", message: errMsg, preferredStyle: .alert)
               let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
               controller.addAction(okAction)
               present(controller, animated: true, completion: nil)
        }
    }
    
    // MARK: - Custom
    
    func toggleLoading(enable: Bool) {
        if enable {
            loadBGView.isHidden = false
            activityView.startAnimating()
        } else {
            loadBGView.isHidden = true
            activityView.stopAnimating()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as? UpdateViewController // 指定要去的controller
        
        if let user = sender as? UserModel {
            controller?.objectID = user.objID
            controller?.stoken = user.token
        }
        
        
    }
}

extension LoginViewController: APIManagerDelegate {
    
    func didLogin(_ apiManager: APIManager, user: UserModel) {
        let token = user.token
        let objID = user.objID
        
        print("Get new objID \(objID) token \(token) ")
        
        DispatchQueue.main.async {
            self.toggleLoading(enable: false)
            self.performSegue(withIdentifier: K.loginSegue, sender: user)
        }
    }
    
    func didFailedWithError(err: Error) {
        print(err)
        
        DispatchQueue.main.async {
            self.toggleLoading(enable: false)
        }
    }
    
    func didFailedWithErr(err: ErrModel) {
        DispatchQueue.main.async {
            self.toggleLoading(enable: false)
            
            let errMsg = "Err Code: \(err.errorCode) \n message: \(err.errorMsg)"
            
            let controller = UIAlertController(title: "Warning!", message: errMsg, preferredStyle: .alert)
               let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
               controller.addAction(okAction)
            self.present(controller, animated: true, completion: nil)
        }
    }
}

