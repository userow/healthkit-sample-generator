//
//  ViewController.swift
//  HealthKitSampleGenerator
//
//  Created by Michael Seemann on 10/01/2015.
//  Copyright (c) 2015 Michael Seemann. All rights reserved.
//

import UIKit
import HealthKitSampleGenerator


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        TestThePod.sayHello()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

