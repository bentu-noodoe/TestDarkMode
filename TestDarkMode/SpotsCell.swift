//
//  SpotsCell.swift
//  Sunray
//
//  Created by ZhengXun Tu on 2018/10/11.
//  Copyright © 2018 Noodoe. All rights reserved.
//

import UIKit

class SpotsCell: UITableViewCell {

    @IBOutlet var topBar: UIView!
    @IBOutlet var bottomBar: UIView!
    @IBOutlet var pinImageView: UIImageView!
    @IBOutlet var indexLabel: UILabel!
    @IBOutlet var nameTextView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    func configure(_ index: Int, name: String?, showTopBar: Bool, showBottomBar: Bool) {
        indexLabel.text = "\(index)"
        nameTextView.text = name ?? ""
        topBar.isHidden = !showTopBar
        bottomBar.isHidden = !showBottomBar
    }
    
    static func estimatedHeight() -> CGFloat {
        return 44
    }

}
