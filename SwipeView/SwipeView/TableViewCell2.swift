//
//  TableViewCell2.swift
//  SwipeView
//
//  Created by WangHui on 2017/4/7.
//  Copyright © 2017年 WangHui. All rights reserved.
//

import UIKit

class TableViewCell2: UITableViewCell {

    @IBOutlet weak var swipeView: SwipeView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let infoView = UINib(nibName: "TableViewCell", bundle: nil).instantiate(withOwner: self, options: nil).first as! TableViewCell
        
        // swipeView.conV.addSubview(infoView.infoView)
        
        infoView.infoView.snp.makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsets.zero)
        }
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
