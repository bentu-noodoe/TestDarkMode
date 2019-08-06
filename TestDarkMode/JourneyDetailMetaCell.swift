//
//  JourneyDetailMetaCell.swift
//  Sunray
//
//  Created by ZhengXun Tu on 2018/10/11.
//  Copyright © 2018 Noodoe. All rights reserved.
//

import UIKit

final class JourneyDetailMetaCell: UITableViewCell {

    @IBOutlet private var dateCreatedTextView: UITextView!
    @IBOutlet private var createdDateTitleLabel: UILabel!
    @IBOutlet private var createrTitleLabel: UILabel!
    @IBOutlet private var createrButton: UIButton!
    
    private var createrBtnPressedClosure: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        configureStaticTexts()
        dateCreatedTextView.textContainerInset = .zero
        dateCreatedTextView.textContainer.lineFragmentPadding = 0
    }
    
    private func configureStaticTexts() {
        createdDateTitleLabel.text = String.localizedString("CreatedDate")
        createrTitleLabel.text = String.localizedString("Creater")
    }
    
    func configure(_ dateCreated: String?, creater: String?, createrBtnPressedClosure: (() -> Void)?) {
        dateCreatedTextView.text = dateCreated ?? ""
        createrButton.setTitle(creater ?? "", for: .normal)
        self.createrBtnPressedClosure = createrBtnPressedClosure
    }

    @IBAction func createrBtnPressed(_ sender: Any) {
        createrBtnPressedClosure?()
    }
    
    static func estimatedHeight() -> CGFloat {
        return 58
    }
    
}
