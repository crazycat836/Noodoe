//
//  Timezone.swift
//  Noodoe assignment
//
//  Created by Gary Shih on 2021/8/6.
//

import Foundation

public class Timezone {
    var offset: Double
    var cityName: String
    
    init(cityName: String, offset: Double) {
        self.offset = offset
        self.cityName = cityName
    }
    
    
    func getTimeZoneList() -> [String] {
        var arrResult: [String] = []
        let dateFormatter = DateFormatter()
        let myDate = Date()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .long
        dateFormatter.dateFormat = "ZZZ"
        (NSTimeZone.knownTimeZoneNames as NSArray).enumerateObjects({ obj, idx, stop in
            let timeZone = NSTimeZone(name: obj as! String)
            dateFormatter.timeZone = timeZone as TimeZone?
            let dateString = dateFormatter.string(from: myDate)
            let mu = NSMutableString(string: dateString)
            mu.insert(":", at: 3)
            let strResult = "(GMT\(mu))\(obj)"
            arrResult.append(strResult)
        })
        
        
        let sortedUsers = arrResult.sorted {
            $0 > $1
        }
        
        var sortArr: [String] = []

        for i in 0..<sortedUsers.count {
            let str = sortedUsers[i]
            let range = (str as NSString?)?.range(of: "+")
            if range?.location == NSNotFound {
                sortArr.append(str)
            }
        }
        var i = sortedUsers.count - 1
        while i >= 0 {
            let str = sortedUsers[i]
            let range = (str as NSString?)?.range(of: "+")
            if range?.location != NSNotFound {
                sortArr.append(str)
            }
            i -= 1
        }
        
        return sortArr
    }

    func formatTimezone(timezone: String) -> [String: Any] {
        
        var offset = 0.0
        var tz = ""

        if timezone.contains("+") {
            let firstSplit = timezone.components(separatedBy: "+")
            let temp = firstSplit[1]

            let split = temp.components(separatedBy: ")")
            tz = "\("+")\(split[0])"
            
            let tzSplit = tz.components(separatedBy: ":")
            
            offset += Double(tzSplit[0]) ?? 0.0
            
            if tzSplit[1] == "30" {
               offset += 0.5
            }
            
            return ["offset": offset, "name": split[1]]
            
        } else if timezone.contains("-") {
            let firstSplit = timezone.components(separatedBy: "-")
            let temp = firstSplit[1]
            
            let split = temp.components(separatedBy: ")")
            tz = "\("-")\(split[0])"
         
            let tzSplit = tz.components(separatedBy: ":")
            
            offset += Double(tzSplit[0]) ?? 0.0
            
            if tzSplit[1] == "00" {
                offset += 0.5
            }
            offset = -offset
            return ["offset": offset, "name": split[1]]
        }
        
        return ["offset": self.offset, "name": self.cityName]
    }

}


