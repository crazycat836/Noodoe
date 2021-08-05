//
//  TimeZonePickerDataSource.swift
//  Noodoe assignment
//
//  Created by Gary Shih on 2021/8/6.
//

import UIKit

protocol TimeZonePickerDataSourceDelegate: AnyObject {
    func timeZonePickerDataSource(_ timeZonePickerDataSource: TimeZonePickerDataSource, didSelectTimeZone timeZone: Timezone)
}

final class TimeZonePickerDataSource: NSObject {
    
    private let tableView: UITableView
    private var timeZones: [String] = []
    var tz : Timezone {
        
        let seconds = TimeZone.current.secondsFromGMT()
        let hours = Double (seconds) / 3600
        let minutes = abs(seconds/60) % 60
        
        let tz = hours + Double(minutes)/60.0
        
        return Timezone(cityName: TimeZone.current.identifier, offset: tz)
    }
    private var searchText = ""
    private var filteredTimeZones: [String] {
        if searchText.isEmpty {
            return timeZones
        } else {
            return timeZones.filter({ return $0.contains(searchText) })
        }
    }
    
    weak var delegate: TimeZonePickerDataSourceDelegate?
    
    init(tableView: UITableView) {
        self.tableView = tableView
        super.init()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func update(onComplete: @escaping (_ successful: Bool) -> ()) {
        DispatchQueue.global(qos: .userInitiated).async {
            
            DispatchQueue.main.async {
                self.timeZones = self.tz.getTimeZoneList()
                self.filter("")
                onComplete(true)
            }
        }
    }
    
    func filter(_ searchString: String) {
        searchText = searchString
    }
}

extension TimeZonePickerDataSource: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredTimeZones.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "cell") {
            cell.textLabel?.text = filteredTimeZones[indexPath.item]
            return cell
        }
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = filteredTimeZones[indexPath.item]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedItem = filteredTimeZones[indexPath.item]
        
        let info = tz.formatTimezone(timezone: selectedItem)
        
        let newTimezone = Timezone(cityName: info["name"] as! String, offset: info["offset"] as! Double)
        
        print("cityName:\(newTimezone.cityName) offset:\(newTimezone.offset)")
        
        delegate?.timeZonePickerDataSource(self, didSelectTimeZone: newTimezone)
    }
    
}
