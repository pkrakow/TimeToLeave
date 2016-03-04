//
//  DestinationTableViewCell.swift
//  TimeToLeave
//
//  Created by Paul Krakow on 1/26/16.
//  Copyright © 2016 Paul Krakow. All rights reserved.
//

import UIKit

class DestinationTableViewCell: UITableViewCell {
    
    // MARK: Properties    
    @IBOutlet weak var nameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
