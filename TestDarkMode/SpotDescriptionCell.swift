//
//  SpotDescriptionCell.swift
//  Sunray
//
//  Created by ZhengXun Tu on 2018/10/9.
//  Copyright © 2018 Noodoe. All rights reserved.
//

import UIKit

class SpotDescriptionCell: UITableViewCell {
    
    @IBOutlet var textView: UITextView!
    
    private static let textViewFont = UIFont(name: "Lato-Regular", size: 12.0) ?? UIFont.systemFont(ofSize: 12, weight: .regular)
    private static let textViewInset = UIEdgeInsets(top: 40, left: 18, bottom: 24, right: 18)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = SpotDescriptionCell.textViewInset
    }
    
    func configure(_ description: String?) {
        textView.text = description ?? ""
    }
    
    func willDisplay() {
        contentView.layoutIfNeeded()
        textView.sizeToFit()
    }
    
    static func estimatedHeight(forText text: String, availableWidth width: CGFloat) -> CGFloat {
        
        guard !text.isEmpty else {
            return 0.0
        }
        
        let width = width - textViewInset.left - textViewInset.right
        return ceil(text.rect(withLimitedWidth: width, andFont: textViewFont).height) + textViewInset.top + textViewInset.bottom
    }
    
}
