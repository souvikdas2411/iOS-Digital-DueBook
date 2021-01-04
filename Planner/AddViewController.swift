//
//  AddViewController.swift
//  Planner
//
//  Created by Souvik Das on 04/01/21.
//

import UIKit
import RealmSwift

class AddViewController: UIViewController {
    @IBOutlet var name : UITextField!
    @IBOutlet var dues : UITextField!
    @IBOutlet var paid : UITextField!
    @IBOutlet var datePicker : UIDatePicker!
   
    
    private let realm = try! Realm()
    public var completionHandler: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Looks for single or multiple taps.
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
        
    }
    @IBAction func didTapSave(){
        if let name = name.text, let dues = dues.text, let paid = paid.text, !name.isEmpty, !dues.isEmpty, !paid.isEmpty {
            
            let date = datePicker.date
            
            realm.beginWrite()
            
            let newItem = PlannerItem()
            let uuid = UUID().uuidString
            newItem.name = name
            newItem.due = dues
            newItem.paid = paid
            newItem.dueDate = date
            newItem.uuid = uuid
            
            let newItem1 = MainItem()
            newItem1.uuid = uuid
            newItem1.paid = paid
            newItem1.payDate = Date()
            
            completionHandler?()
            realm.add(newItem)
            realm.add(newItem1)
            try! realm.commitWrite()
            
            navigationController?.popToRootViewController(animated: true)
        }
        else{
            tap()
        }
        
        
    }
    func tap() {
        let uialert = UIAlertController(title: "Error", message: "Please fill in the details", preferredStyle: UIAlertController.Style.alert)
        uialert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: nil))
       self.present(uialert, animated: true, completion: nil)
    }
    
    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
}
