//
//  ExampleVC.swift
//  SmileFaceUnlock
//
//  Created by Human on 7/31/22.
//  Copyright © 2022 Shelley, Jake. All rights reserved.
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
