//
//  ItemViewController.swift
//  Planner
//
//  Created by Souvik Das on 04/01/21.
//

import UIKit
import RealmSwift

class ItemViewController: UIViewController {
    
    @IBOutlet var table: UITableView!
    @IBOutlet var datePicker : UIDatePicker!
    @IBOutlet var add : UITextField!
    @IBOutlet var due : UITextField!
    @IBOutlet var label : UILabel!
    
    public var item : PlannerItem?
    private var content = [MainItem]()
    public var deletionHandler : (() -> Void)?
    private var data = [MainItem]()
    private let realm = try! Realm()
    private var total = 0
    public var completionHandler: (() -> Void)?
    
    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        return dateFormatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        datePicker.date  = item!.dueDate
        table.delegate = self
        table.dataSource = self
        table.tableFooterView = UIView()
        
        //Looks for single or multiple taps.
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
        
        refresh()
        
        
        
    }
    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    @IBAction func didTapUpdate(){
        let newItem = MainItem()
        completionHandler?()
        try! realm.write{
            item?.dueDate = datePicker.date
        }
        if let addP = add.text, let uuid = item?.uuid, !addP.isEmpty, !uuid.isEmpty{
            add.resignFirstResponder()
            add.text = ""
            newItem.paid = addP
            newItem.payDate = Date()
            newItem.uuid = uuid
            realm.beginWrite()
            realm.add(newItem)
            try! realm.commitWrite()
            refresh()
        }
    }
    func getData(){
        content.removeAll()
        total = 0
        data = realm.objects(MainItem.self).map({$0})
        for i in data {
            if i.uuid == item?.uuid {
                content.append(i)
                total = total + Int(i.paid)!
            }
        }
        content.sort {($0.payDate > $1.payDate)}
        table.reloadData()
        updateLabel()
    }
    
    func updateLabel(){
        due.text = item?.due
        let temp = Int(item!.due)!
        let rem = temp - total
        label.text = "Amount to be paid : ₹\(rem)"
    }
    func refresh(){
        getData()
    }
}
extension ItemViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return content.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell2", for: indexPath)
        let i = "Paid ₹\(content[indexPath.row].paid)"
        let d = Self.dateFormatter.string(from: data[indexPath.row].payDate)
        cell.textLabel?.text = i
        cell.detailTextLabel?.text = d
        
        return cell
    }
    
    
}
