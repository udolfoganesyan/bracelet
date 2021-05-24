//
//  ConversationCell.swift
//  FintechApp
//
//  Created by Rudolf Oganesyan on 25.09.2020.
//  Copyright © 2020 Рудольф О. All rights reserved.
//

import UIKit

protocol ConfigurableView {
    associatedtype ConfigurationModel
    func configure(with model: ConfigurationModel)
}

final class ConversationCell: UITableViewCell {
    
    @IBOutlet private weak var avatarContainer: UIView!
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    
    private lazy var onlineBadge = OnlineBadgeView()
    private lazy var avatarView = AvatarImageView(style: .circle)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        avatarContainer.addSubviewInBounds(avatarView)
        onlineBadge.install(on: avatarContainer)
        
        containerView.layer.cornerRadius = 12
        containerView.layer.masksToBounds = true
        containerView.layer.borderWidth = 2
        containerView.layer.borderColor = UIColor.black.withAlphaComponent(0.5).cgColor
        backgroundColor = .clear
        let backgroundColorView = UIView()
        backgroundColorView.backgroundColor = UIColor.darkGray.withAlphaComponent(0.3)
        self.selectedBackgroundView = backgroundColorView
    }
}

// MARK: - ConfigurableView

extension ConversationCell: ConfigurableView {
    
    func configure(with model: ConversationCellModel) {
        let theme = model.theme
        nameLabel.textColor = theme.primaryTextColor
        dateLabel.textColor = theme.secondaryTextColor
        
        nameLabel.text = model.name
        avatarView.setupWith(firstName: model.name, color: .randomLightColor)
        
        dateLabel.text = model.date
        
        if model.message.isEmpty {
            dateLabel.text = ""
        }
    }
}
