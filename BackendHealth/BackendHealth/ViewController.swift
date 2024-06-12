//
//  ViewController.swift
//  BackendHealth
//
//  Created by Carlos Paredes on 6/12/24.
//
//
//import Foundation
//import UIKit
//import SwiftUI
//class ViewController: UIViewController {
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        let swiftUIView = ContentView()
//        let hostingController = UIHostingController(rootView:swiftUIView)
//        addChild(hostingController)
//        view.addSubview(hostingController.view)
//        
//        HealthKitManager.shared.requestAuthorization { (success, error) in
//            if success {
//                self.fetchAndPrepareData()
//            } else {
//                print("HealthKit authorization failed: \(String(describing: error))")
//            }
//        }
//    }
//    
//    
//}
