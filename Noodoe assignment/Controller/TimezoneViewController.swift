//
//  Timezone.swift
//  Noodoe assignment
//
//  Created by Gary Shih on 2021/8/6.
//

import UIKit

public protocol TimeZonePickerDelegate: AnyObject {
    func timeZonePicker(_ timeZonePicker: TimeZonePickerViewController, didSelectTimeZone timeZone: Timezone)
}

public final class TimeZonePickerViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!

    @IBOutlet weak var tableView: UITableView!
    
    public class func getVC(withDelegate delegate: TimeZonePickerDelegate) -> TimeZonePickerViewController? {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle(for: TimeZonePickerViewController.self))
        
        guard let vc = storyboard.instantiateViewController(identifier:  "TimezoneViewController") as? TimeZonePickerViewController else {
            return nil
        }
        vc.delegate = delegate
        return vc

    }
    
    private lazy var dataSource: TimeZonePickerDataSource = {
        let ds = TimeZonePickerDataSource(tableView: self.tableView)
        ds.delegate = self
        return ds
    }()
    
    weak var delegate: TimeZonePickerDelegate?

    override public func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureSearchBar()
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        update()
        DispatchQueue.main.async {
            self.searchBar.becomeFirstResponder()
        }
    }
    
    private func update() {
        dataSource.update { _ in
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    private func configureTableView() {
        tableView.tableFooterView = UIView()
        tableView.keyboardDismissMode = .onDrag
    }
    
    private func configureSearchBar() {
        searchBar.delegate = self
    }
    
    @IBAction func cancelTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension TimeZonePickerViewController: UISearchBarDelegate {
    
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        dataSource.filter(searchText)
        tableView.reloadData()
    }
    
}

extension TimeZonePickerViewController: TimeZonePickerDataSourceDelegate {
    
    func timeZonePickerDataSource(_ timeZonePickerDataSource: TimeZonePickerDataSource, didSelectTimeZone timeZone: Timezone) {
        delegate?.timeZonePicker(self, didSelectTimeZone: timeZone)
    }
    
}
