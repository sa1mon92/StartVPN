//
//  CountriesTableViewCell.swift
//  StartVPN
//
//  Created by Дмитрий Садырев on 07.06.2022.
//

import UIKit

class CountriesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var countryImage: UIImageView!
    @IBOutlet weak var countryLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func set(viewModel: CountryCellViewModelType) {
        countryLabel.text = viewModel.countryName
        countryImage.image = viewModel.countryImage
    }
}
