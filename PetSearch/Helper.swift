//
//  File.swift
//  PetSearch
//
//  Created by KK on 2018/5/13.
//  Copyright © 2018 Denis Eltcov. All rights reserved.
//

import Foundation
import UIKit

func alertMessage(in inView: UIViewController, title: String, message alert: String, callback handler: ((UIAlertAction) -> Void)? = nil) {
    let message = UIAlertController(title: title, message: alert, preferredStyle: .alert)
    let action = UIAlertAction(title: "OK", style: .default, handler: handler)
    message.addAction(action)
    message.popoverPresentationController?.sourceView = inView.view as UIView
    inView.present(message, animated: true, completion: nil)
}

func confirmMessage(in inView: UIViewController, message alert: String, confirmText: String, confirmMethod confirmCallback: ((UIAlertAction) -> Void)? = nil, cancel cancelCallback: ((UIAlertAction) -> Void)? = nil) {
    let confirmationController = UIAlertController(title: "", message: alert, preferredStyle: .actionSheet)
    let confirmAction = UIAlertAction(title: confirmText, style: .destructive, handler: confirmCallback)
    let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: cancelCallback)
    confirmationController.addAction(confirmAction)
    confirmationController.addAction(cancel)
    
    confirmationController.popoverPresentationController?.sourceView = inView.view as UIView
    // adjust the position of popover
    confirmationController.popoverPresentationController?.sourceRect = .init(x: inView.view.frame.size.width / 2, y: inView.view.frame.size.height, width: 0, height: 0)
    inView.present(confirmationController, animated: true) {}
}
