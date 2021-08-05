//
//  ErrData.swift
//  Noodoe assignment
//
//  Created by Gary Shih on 2021/8/4.
//

import Foundation

//{
//    "code": 209,
//    "error": "Invalid session token"
//}

struct ErrData: Codable {
    let code: Int
    let error: String
}
