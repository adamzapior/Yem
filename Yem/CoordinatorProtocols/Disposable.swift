//
//  Disposable.swift
//  Yem
//
//  Created by Adam Zapiór on 28/03/2024.
//

import Foundation

/// All view controllers that perform tasks which should be cancelled once the view controller is dismissed should conform to this protocol.
protocol DisposableViewController: NSObjectProtocol {
    func cleanUp()
}
