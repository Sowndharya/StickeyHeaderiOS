//
//  InitialTableViewCell.swift
//  StickeyHeaderiOS
//
//  Created by Sowndharya M on 20/04/19.
//  Copyright © 2019 Sowndharya M. All rights reserved.
//

import UIKit

let InitialTableViewCellID = "InitialTableViewCell"
class InitialTableViewCell: UITableViewCell {

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
