//
//  ChooseRoleViewController.swift
//  FintechApp
//
//  Created by Rudolf Oganesyan on 25.05.2021.
//  Copyright © 2021 Рудольф О. All rights reserved.
//

import UIKit

class ChooseRoleViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func centralAction(_ sender: UIButton) {
        let vc = CentralViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func peripheralAction(_ sender: UIButton) {
        let vc = PeripheralViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}
