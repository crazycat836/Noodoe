//
//  UpdateViewController.swift
//  Noodoe assignment
//
//  Created by Gary Shih on 2021/8/4.
//

import UIKit

class UpdateViewController: UIViewController {

    
    @IBOutlet weak var loadBGView: UIView!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    @IBOutlet weak var timeZoneName: UILabel!
    @IBOutlet weak var timeZoneOffset: UILabel!
    
    var apiManager = APIManager()
    
    var objectID: String?
    var stoken: String?
    
    var tz: Double?
    let net = NetworkStatus.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let seconds = TimeZone.current.secondsFromGMT()
        let hours = Double (seconds) / 3600
        let minutes = abs(seconds/60) % 60
        
        tz = hours + Double(minutes)/60.0
        
        timeZoneName.text = "Local Timezone: \(TimeZone.current.identifier)"
        timeZoneOffset.text = "Local Timezone offset: \(tz ?? 0.0)"
        
        apiManager.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        toggleLoading(enable: false)
    }
    
    // MARK: - Action
    
    @IBAction func selectPressed(_ sender: UIButton) {
         
        if let timeZonePicker = TimeZonePickerViewController.getVC(withDelegate: self) {
            present(timeZonePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func updaloadPressed(_ sender: UIButton) {
        // check newwork connect
        if net.isOn {
            if let timezone = tz {
                
                toggleLoading(enable: true)
                
                apiManager.updateData(timezone: timezone, obiID: objectID, token: stoken)
            }
        } else {
            let errMsg = "Please check network connect"
            
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
    
}

extension UpdateViewController: APIManagerDelegate {
    
    func didUpdateUser(_ apiManager: APIManager) {
        print("Update User Complete")
        
        DispatchQueue.main.async {
            self.toggleLoading(enable: false)
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

extension UpdateViewController: TimeZonePickerDelegate {
    
    func timeZonePicker(_ timeZonePicker: TimeZonePickerViewController, didSelectTimeZone timeZone: Timezone) {
        tz = timeZone.offset
        
        timeZoneName.text = "Current Timezone: \(timeZone.cityName)"
        timeZoneOffset.text = "Timezone offset: \(timeZone.offset)"
        
        timeZonePicker.dismiss(animated: true, completion: nil)
    }
}
