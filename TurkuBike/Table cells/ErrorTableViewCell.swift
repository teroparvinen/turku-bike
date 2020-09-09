//
// Errors are displayed on the UI with an image and a textual description of the error.
// The user has the option to retry the retrieval.
//

import UIKit

class ErrorTableViewCell: UITableViewCell {

	var errorImageView: UIImageView!
	var descriptionLabel: UILabel!
	var refreshButton: UIButton!
	
	var stackView: UIStackView!
	
	// The description string, should be set at creation time
	var errorDescription: String! {
		didSet {
			descriptionLabel.text = errorDescription
		}
	}
	
	// A callback for use by the table view controller for passing the request to reload data up to the controller
	typealias ReloadCallback = () -> ()
	var reloadCallback: ReloadCallback?
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		errorImageView = UIImageView(image: UIImage(named: "BrokenBike"))
		errorImageView.tintColor = .tertiaryLabel
		
		descriptionLabel = UILabel()
		descriptionLabel.numberOfLines = 0
		
		refreshButton = UIButton()
		refreshButton.setTitle(NSLocalizedString("Retry", comment: "Error cell"), for: .normal)
		refreshButton.setTitleColor(refreshButton.tintColor, for: .normal)
		refreshButton.addTarget(self, action: #selector(refreshTapped(_:)), for: .touchUpInside)
		
		// Place the controls in a vertical stack view
		stackView = UIStackView(arrangedSubviews: [errorImageView, descriptionLabel, refreshButton])
		stackView.axis = .vertical
		stackView.alignment = .center
		stackView.spacing = 10
		contentView.addSubview(stackView)
		stackView.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, bottom: contentView.bottomAnchor, right: contentView.rightAnchor, insets: UIEdgeInsets(top: 15, left: 0, bottom: 15, right: 0))
	}
	
	@objc func refreshTapped(_ sender: UIButton) {
		reloadCallback?()
	}
	
	required init?(coder: NSCoder) {
		fatalError("Storyboards are not supported")
	}
	
}
