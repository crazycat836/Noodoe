//
//  UserData.swift
//  Noodoe assignment
//
//  Created by Gary Shih on 2021/8/2.
//

import Foundation

//{
//    "objectId": "WkuKfCAdGq",
//    "username": "test2@qq.com",
//    "code": "4wtmah5h",
//    "isVerifiedReportEmail": true,
//    "reportEmail": "test2@qq.com",
//    "createdAt": "2019-07-12T07:07:18.027Z",
//    "updatedAt": "2021-08-02T12:39:46.701Z",
//    "timezone": -8,
//    "parameter": 8,
//    "number": 5,
//    "phone": "415-369-6666",
//    "ACL": {
//        "WkuKfCAdGq": {
//            "read": true,
//            "write": true
//        }
//    },
//    "sessionToken": "r:dd86b6f32ff4f45b5aaf236decaa0e03"
//}


struct UserData: Codable {
    let username: String
    let sessionToken: String
    let timezone: Int
    let objectId: String
}
