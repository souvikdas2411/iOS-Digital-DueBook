//
//  ViewController.swift
//  Planner
//
//  Created by Souvik Das on 04/01/21.
//

import UIKit
import RealmSwift

class PlannerItem: Object{
    @objc dynamic var name: String = ""
    @objc dynamic var dueDate: Date = Date()
    @objc dynamic var due: String = ""
    @objc dynamic var paid: String = ""
    @objc dynamic var uuid: String = ""

}
class MainItem: Object{
    @objc dynamic var uuid: String = ""
    @objc dynamic var paid: String = ""
    @objc dynamic var payDate: Date = Date()

}

class ViewController: UIViewController {
    
    @IBOutlet var table : UITableView!
    
    private var data = [PlannerItem]()
    private let realm = try! Realm()
    
    static let dateFormatter1: DateFormatter = {
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateStyle = .full
        return dateFormatter1
    }()

    override func viewDidLoad() {
        
        data = realm.objects(PlannerItem.self).map({$0})
        data.sort {($0.dueDate < $1.dueDate)}
        
        table.delegate = self
        table.dataSource = self
        table.tableFooterView = UIView()
        print(data)
        
    }
    
    @IBAction func didTapAdd(){
        guard let vc = storyboard?.instantiateViewController(identifier: "add") as? AddViewController else {
            return
        }
        vc.completionHandler = {
            DispatchQueue.main.async {
                self.refresh()
            }
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func refresh(){
        data = realm.objects(PlannerItem.self).map({$0})
        
        //data = realm.objects(ToDoListItem.self)
        data.sort {($0.dueDate < $1.dueDate)}
        table.reloadData()
    }


}
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let i = data[indexPath.row].name
        let d = Self.dateFormatter1.string(from: data[indexPath.row].dueDate)
        cell.textLabel?.text = i
        cell.detailTextLabel?.text = d
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = data[indexPath.row]
        guard let vc = storyboard?.instantiateViewController(identifier: "item") as? ItemViewController else {
            return
        }
        vc.completionHandler = {
            DispatchQueue.main.async {
                self.refresh()
            }
        }
        vc.item = item
        navigationController?.pushViewController(vc, animated: true)
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        
        return .delete
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath){
        if editingStyle == .delete{
            let item = data[indexPath.row]
            let temp = realm.objects(MainItem.self).map({$0})
            for i in temp {
                if i.uuid == item.uuid {
                    realm.beginWrite()
                    realm.delete(i)
                    try! realm.commitWrite()
                }
            }
            realm.beginWrite()
            realm.delete(item)
            try! realm.commitWrite()
            self.refresh()
        }
    }
    
    
}

