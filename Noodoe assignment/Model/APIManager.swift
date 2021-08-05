//
//  APIManager.swift
//  Noodoe assignment
//
//  Created by Gary Shih on 2021/8/3.
//

import Foundation

enum APIErrStatus {
    case LoginFailed
    case TokenErr
}

enum APIType {
    case Login
    case UpdateUser
}


protocol APIManagerDelegate {
    func didLogin(_ apiManager: APIManager, user: UserModel)
    func didUpdateUser(_ apiManager: APIManager)
    func didFailedWithError(err: Error)
    func didFailedWithErr(err: ErrModel)
}

extension APIManagerDelegate {
    
    //prevent implement warning
    
    func didUpdateUser(_ apiManager: APIManager){
        
    }
    
    func didLogin(_ apiManager: APIManager, user: UserModel) {
        
    }
}


class APIManager {
    var delegate: APIManagerDelegate?
    let baseURL = "https://watch-master-staging.herokuapp.com/api"
    let apiKey = ""
    let applicationID = "vqYuKPOkLQLYHhk4QTGsGKFwATT4mBIGREI2m8eD"
    
    var objectID: String?
    var stoken: String?
    
    func login(userName: String, password: String) {
        let parameters: [String: Any] = [
            "username": userName,
            "password": password
        ]
        
        performRequest(with: baseURL + "/login", parameters: parameters, apiType: .Login)
    }
    
    func updateData(timezone: Double, obiID: String?, token: String?) {
        let parameters: [String: Any] = [
            "timezone": timezone
        ]
        
        objectID = obiID
        stoken = token
        
        if let objID = objectID {
            performRequest(with: baseURL + "/users" + "/\(objID)", parameters: parameters, apiType: .UpdateUser)
        } else {
           print("objID nil")
        }
    }
    
    func generateRequest(with urlString: String, parameters: [String: Any], type: APIType) -> URLRequest? {
        
        if let url = URL(string: urlString) {
            
            var request = URLRequest(url: url)
            let method = generateMethod(type: type)
            request.httpMethod = method
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
            request.setValue(applicationID, forHTTPHeaderField: "X-Parse-Application-Id")
            request.setValue(apiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
            
            if(type == .UpdateUser) {
                
                print("token \(stoken ?? "")")
                request.setValue(stoken, forHTTPHeaderField: "X-Parse-Session-Token")
            }
            
            do {
                // pass dictionary to nsdata object and set it as request body
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
            } catch let error {
                print(error.localizedDescription)
            }
            
            request.timeoutInterval = 20
            return request
        }
        return nil
        
    }
    
    
    func performRequest(with urlString: String, parameters: [String: Any], apiType type: APIType) {
        print("perform url \(urlString)")
        guard let request = generateRequest(with: urlString, parameters: parameters, type: type) else { return }
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil {
                self.delegate?.didFailedWithError(err: error!)
                return
            }
            
            self.parseResult(data: data, response: response, apiType: type)
        }
        
        task.resume()
    }
    
    func parseResult(data: Data?, response: URLResponse?, apiType type: APIType) {
        guard let response = response as? HTTPURLResponse else { return }
        
        print("Receive status Code \(response.statusCode)")
        
        guard let data = data else {
            return
        }
        
        do {
            //create json object from data
            if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                print(json)
                // handle json...
            }
        } catch let error {
            print(error.localizedDescription)
        }
        
        
        switch response.statusCode {
        case 200:
            print("200 OK")
            
            switch type {
            case .Login:
                if let user = parseJSON(data) {
                    delegate?.didLogin(self, user: user)

                }
            case .UpdateUser:
                delegate?.didUpdateUser(self)
            }
        case 400...499:
            // if receive some error pass to viewcontroller
            if let err = parseErr(data) {
                delegate?.didFailedWithErr(err: err)
            }
        default:
            print("Unknown code")
        }
    }
    
    func parseErr(_ userData: Data) -> ErrModel? {
        let decoder = JSONDecoder()
        
        do {
            let decodeData = try decoder.decode(ErrData.self, from: userData)
            let errCode = decodeData.code
            let msg = decodeData.error
            
            let err = ErrModel(errorMsg: msg, errorCode: errCode)
            
            return err
            
        } catch {
            delegate?.didFailedWithError(err: error)
            return nil
        }
    }
    
    func parseJSON(_ userData: Data) -> UserModel? {
        let decoder = JSONDecoder()
        
        do {
            let decodeData = try decoder.decode(UserData.self, from: userData)
            let timeZone = decodeData.timezone
            let username = decodeData.username
            let sessionToken = decodeData.sessionToken
            let objID = decodeData.objectId
            
            let user = UserModel(name: username, token: sessionToken, timezone: timeZone, objID: objID)
            
            return user
            
        } catch {
            delegate?.didFailedWithError(err: error)
            return nil
        }
    }
    
    func generateMethod(type: APIType) -> String {
        switch type {
        case .Login:
            return "POST"
        case .UpdateUser:
            return "PUT"
        }
    }
}
