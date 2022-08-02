//
//  ExampleVC.swift
//  SmileFaceUnlock
//
//  Created by Muhammad Afham on 7/31/22.
//  Copyright © Muhammad Afham. All rights reserved.
//

import UIKit

class ExampleVC: UIViewController {
    var isUnlocked: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    override func viewDidAppear(_ animated: Bool) {
        guard !isUnlocked else { return }
        isUnlocked = true
        SmileLockVC.present(callingVC: self)
    }

}
