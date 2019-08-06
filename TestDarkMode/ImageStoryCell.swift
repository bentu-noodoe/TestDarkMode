//
//  ImageStoryCell.swift
//  Sunray
//
//  Created by ZhengXun Tu on 2018/10/9.
//  Copyright © 2018 Noodoe. All rights reserved.
//

import UIKit

class ImageStoryCell: UITableViewCell {
    
    @IBOutlet var photoImageview: CacheImageView!
    @IBOutlet var photoImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var descriptionBackgroundView: UIView!
    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet var descriptionTextViewHeightConstraint: NSLayoutConstraint!
    
    static let descriptionTextViewTextContainerInset = UIEdgeInsets(top: 0, left: 17, bottom: 24, right: 17)
    static let descriptionTextViewFont = UIFont(name: "Lato-Regular", size: 13)!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        descriptionTextView.textContainerInset = ImageStoryCell.descriptionTextViewTextContainerInset
        descriptionTextView.textContainer.lineFragmentPadding = 0
    }
    
    func configure(_ imageStory: Spot.ImageStory?, placeholderImage: UIImage?) {
        if let urlString = imageStory?.photo?.url?.absoluteString {
            photoImageview.setImageUrl(urlString, placeholder: placeholderImage)
        } else {
            photoImageview.image = nil
        }
        if let description = imageStory?.photoDescription, !description.isEmpty {
            descriptionBackgroundView.isHidden = false
            descriptionTextView.text = description
        } else {
            descriptionBackgroundView.isHidden = true
        }
        photoImageViewHeightConstraint.constant = ImageStoryCell.estimatedImageHeight(imageStory, width: bounds.width)
        descriptionTextViewHeightConstraint.constant = ImageStoryCell.estimatedTextViewHeight(imageStory, width: bounds.width)
        descriptionTextView.sizeToFit()
        descriptionTextView.setNeedsLayout()
        descriptionBackgroundView.setNeedsLayout()
        contentView.layoutIfNeeded()
    }
    
    static func estimatedHeight(_ imageStory: Spot.ImageStory?, width: CGFloat) -> CGFloat {
        let topSpacing = CGFloat(3)
        let imageHeight = estimatedImageHeight(imageStory, width: width)
        let textViewHeight = estimatedTextViewHeight(imageStory, width: width)
        let stackViewSpacing = textViewHeight != 0 ? CGFloat(6) : CGFloat(0)
        return topSpacing + imageHeight + stackViewSpacing + textViewHeight
    }
    
    static func estimatedImageHeight(_ imageStory: Spot.ImageStory?, width: CGFloat) -> CGFloat {
        if let ratio = imageStory?.photo?.ratio {
            return width / ratio
        } else {
            return 0
        }
    }
    
    static func estimatedTextViewHeight(_ imageStory: Spot.ImageStory?, width: CGFloat) -> CGFloat {
        if let description = imageStory?.photoDescription, !description.isEmpty {
            let height = description.rect(withLimitedWidth: width - descriptionTextViewTextContainerInset.left - descriptionTextViewTextContainerInset.right,
                                          andFont: descriptionTextViewFont).height
            return ceil(height) + abs(descriptionTextViewTextContainerInset.bottom)
        } else {
            return 0
        }
    }
    
}
