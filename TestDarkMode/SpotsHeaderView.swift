//
//  SpotsHeaderView.swift
//  Sunray
//
//  Created by ZhengXun Tu on 2018/10/11.
//  Copyright © 2018 Noodoe. All rights reserved.
//

import UIKit

class SpotsHeaderView: UIView, NibOwnerLoadable {
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var descriptionBackgroundView: UIView!
    @IBOutlet var descriptionTextView: UITextView!
    
    static let descriptionTextViewTextContainerInset = UIEdgeInsets(top: 0, left: 17, bottom: 24, right: 17)
    static let descriptionTextViewFont = UIFont(name: "Lato-Regular", size: 13)!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNibContent()
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNibContent()
        commonInit()
    }
    
    func commonInit() {
        descriptionTextView.textContainerInset = SpotsHeaderView.descriptionTextViewTextContainerInset
        descriptionTextView.textContainer.lineFragmentPadding = 0
    }
    
    func configure(_ name: String?, description: String?) {
        nameLabel.text = name
        if let description = description, !description.isEmpty {
            descriptionBackgroundView.isHidden = false
            descriptionTextView.text = description
        } else {
            descriptionBackgroundView.isHidden = true
        }
    }
    
    func willDisplay() {
        layoutIfNeeded()
        descriptionTextView.sizeToFit()
    }
    
    static func estimatedCellHeightWithDescription(_ description: String?, width: CGFloat) -> CGFloat {
        let textHeight: CGFloat
        if let description = description, !description.isEmpty {
            let height = description.rect(withLimitedWidth: width - descriptionTextViewTextContainerInset.left - descriptionTextViewTextContainerInset.right,
                                          andFont: descriptionTextViewFont).height + abs(descriptionTextViewTextContainerInset.bottom)
            textHeight = ceil(height)
        } else {
            textHeight = 0
        }
        let titleHeight = CGFloat(40)
        let stackViewSpacing = textHeight != 0 ? CGFloat(6) : CGFloat(0)
        return titleHeight + stackViewSpacing + textHeight
    }
    
}
