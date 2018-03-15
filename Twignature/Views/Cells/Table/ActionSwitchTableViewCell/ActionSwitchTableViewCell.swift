//
//  ActionSwitchTableViewCell.swift
//  Twignature
//
//  Created by user on 11/3/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import UIKit

class ActionSwitchTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var switchControl: UISwitch!
    var switchDidChangeValueHandler: Closure<Bool>?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func didChangeSwitchValue(_ sender: Any) {
        switchDidChangeValueHandler?(switchControl.isOn)
    }
    
    func setTitle(_ title: String) {
        titleLabel.text = title
    }
    
    func setFieldValue(_ value: Bool) {
        switchControl.setOn(value, animated: true)
    }
    
    func getFieldValue() -> Bool {
        return switchControl.isOn
    }
}
