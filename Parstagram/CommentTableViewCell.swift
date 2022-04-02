//
//  CommentTableViewCell.swift
//  Parstagram
//
//  Created by OSL on 3/27/22.
//

import UIKit

class CommentTableViewCell: UITableViewCell {

    @IBOutlet weak var commentAuthor: UILabel!
    @IBOutlet weak var commentTextLabel: UILabel!
    @IBOutlet weak var commenterProfileImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
