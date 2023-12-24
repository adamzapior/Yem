//
//  UIViewControllerExt.swift
//  Yem
//
//  Created by Adam Zapiór on 17/12/2023.
//

import Foundation
import UIKit
//
//extension UIViewController {
//    
//    func popUpPicker(for pickerView: UIPickerView, title: String, dataSource: UIPickerViewDataSource, delegate: UIPickerViewDelegate,  updateLabel: @escaping LabelUpdateHandler) {
//        view.endEditing(true)
//        
//        pickerView.dataSource = dataSource
//        pickerView.delegate = delegate
//        pickerView.tag = pickerView.tag
//
//        let vc = UIViewController()
//        vc.preferredContentSize = CGSize(width: view.frame.width - 20, height: 180)
//        pickerView.frame = CGRect(x: 0, y: 0, width: vc.preferredContentSize.width, height: 180)
//        vc.view.addSubview(pickerView)
//
//        let alert = UIAlertController(title: title, message: "", preferredStyle: .actionSheet)
//        alert.popoverPresentationController?.sourceView = view
//        alert.setValue(vc, forKey: "contentViewController")
//
//        let selectAction = UIAlertAction(title: "Select", style: .default, handler: { _ in
//                 let selectedRow = pickerView.selectedRow(inComponent: 0)
//                 let newValue = selectedRow.description
//                 updateLabel(newValue)
//             })
//
//        selectAction.setValue(UIColor.orange, forKey: "titleTextColor")
//
//        alert.addAction(selectAction)
//        present(alert, animated: true, completion: nil)
//    }
//}
//
//
//extension UIViewController {
//    typealias LabelUpdateHandler = (String) -> Void
//}
//
