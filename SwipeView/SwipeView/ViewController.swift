//
//  ViewController.swift
//  SwipeView
//
//  Created by WangHui on 2017/4/6.
//  Copyright © 2017年 WangHui. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBAction func ttt(_ sender: UITapGestureRecognizer) {
        print("ssss")
    }
    @IBOutlet weak var containerView: UIView!

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
//        tableView.delegate = self
//        tableView.dataSource = self
        
//        tableView.register(UINib.init(nibName: "TableViewCell2", bundle: nil) , forCellReuseIdentifier: "cell")
    }

//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 65
//    }
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 10
//    }
//    
//    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        return false
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
//        cell.selectionStyle = .none
//        return cell
//    }


}

