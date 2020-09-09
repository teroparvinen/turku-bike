//
// A cell for the main rack list, showing information for a bike rack.
// Each entry in the list shows the name of the rack, distance to the rack (if available) and the number of bikes by type available at that rack currently.
//

import UIKit
import Combine

class RackTableViewCell: UITableViewCell {

	var nameLabel: UILabel!
	var distanceLabel: UILabel!
	
	var rowStackView: UIStackView!
	var topStackView: UIStackView!
	var bottomStackView: UIStackView!
	
	var locationSubscription: AnyCancellable?
	
	// Reference to the model object, must be populated at creation time
	var rack: Rack! {
		didSet {
			nameLabel.text = rack.name

			// Update the bottom stack view, containing icons and counts for both bike types
			bottomStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

			// Use a low hugging spacer to align the rest of the controls right
			let spacer = UIView()
			spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
			bottomStackView.addArrangedSubview(spacer)
			
			// Set up the bike type counts with icons
			let bikeImage = UIImage(named: "Bike")!
			
			// Some local helper functions to keep things DRY
			@discardableResult func addStatusImage(name: String, color: UIColor) -> UIImageView {
				// Support accessibility sizing by configuring for a text style
				let image = UIImage(systemName: name, withConfiguration: UIImage.SymbolConfiguration(textStyle: .caption1))!
				let imageView = UIImageView(image: image)
				imageView.tintColor = color
				imageView.contentMode = .scaleAspectFit
				bottomStackView.addArrangedSubview(imageView)
				return imageView
			}
			@discardableResult func addBikeImage(color: UIColor) -> UIImageView {
				let bikeImageView = UIImageView(image: bikeImage)
				bikeImageView.tintColor = color
				// Support accessibility sizing through aspect ratio constraint
				bikeImageView.widthAnchor.constraint(equalTo: bikeImageView.heightAnchor, multiplier: bikeImage.size.width / bikeImage.size.height).isActive = true
				bottomStackView.addArrangedSubview(bikeImageView)
				return bikeImageView
			}
			@discardableResult func addLabel(text: String) -> UILabel {
				let label = UILabel()
				label.text = text
				label.font = .preferredFont(forTextStyle: .body)
				bottomStackView.addArrangedSubview(label)
				return label
			}
			
			if rack.classicBikesAvailable == 0 && rack.electricBikesAvailable == 0 {
				// No bikes! Show a warning, a greyed out icon and a zero count
				addStatusImage(name: "exclamationmark.triangle.fill", color: .systemRed)
				addBikeImage(color: .systemGray)
				addLabel(text: String(rack.classicBikesAvailable))
			} else {
				if rack.classicBikesAvailable > 0  {
					addBikeImage(color: .systemGreen)
					let label = addLabel(text: String(rack.classicBikesAvailable))
					
					// If there are both types of bike available, use a larger spacing after the first type
					if rack.electricBikesAvailable > 0 {
						bottomStackView.setCustomSpacing(15, after: label)
					}
				}
				if rack.electricBikesAvailable > 0 {
					let boltImageView = addStatusImage(name: "bolt.fill", color: .systemTeal)

					addBikeImage(color: .systemTeal)
					
					bottomStackView.setCustomSpacing(0, after: boltImageView)
					
					addLabel(text: String(rack.electricBikesAvailable))
				}
			}

			// Track user location info
			locationSubscription = LocationSource.shared.publisher.sink(receiveCompletion: { completion in
				// Hide the distance label on location failure
				if case .failure(_) = completion {
					self.distanceLabel.isHidden = true
				}
			}, receiveValue: { coordinate in
				if let coordinate = coordinate {
					self.distanceLabel.isHidden = false
					
					// Update the distance to the rack
					let formatter = LengthFormatter()
					formatter.numberFormatter.usesSignificantDigits = true
					formatter.numberFormatter.minimumSignificantDigits = 2
					formatter.numberFormatter.maximumSignificantDigits = 2

					let distance = self.rack.coordinate.distance(to: coordinate)
					// Show distances over a kilometer in km, shorter in meters
					if distance > 1000 {
						self.distanceLabel.text = formatter.string(fromValue: distance / 1000, unit: .kilometer)
					} else {
						self.distanceLabel.text = formatter.string(fromValue: distance, unit: .meter)
					}
				}
			})
		}
	}
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		nameLabel = UILabel()
		nameLabel.font = .preferredFont(forTextStyle: .headline)
		
		distanceLabel = UILabel()
		distanceLabel.text = "--"
		distanceLabel.textColor = .secondaryLabel
		distanceLabel.setContentHuggingPriority(.init(251), for: .horizontal)
		distanceLabel.isHidden = true

		// Structure the cell using nested stack views
		
		// The top row contains the name and distance labels
		topStackView = UIStackView(arrangedSubviews: [nameLabel, distanceLabel])
		topStackView.axis = .horizontal
		topStackView.distribution = .fill
		topStackView.alignment = .fill
		topStackView.spacing = 10

		// The bottom row contains bike counts, controls are created when the rack model object is set
		bottomStackView = UIStackView()
		bottomStackView.axis = .horizontal
		bottomStackView.spacing = 5

		// Vertical master stack view to contain both rows
		rowStackView = UIStackView(arrangedSubviews: [topStackView, bottomStackView])
		rowStackView.axis = .vertical
		rowStackView.alignment = .fill
		rowStackView.spacing = 5

		// Anchor the master stack to the content view with nice margins
		contentView.addSubview(rowStackView)
		rowStackView.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, bottom: contentView.bottomAnchor, right: contentView.rightAnchor, insets: UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15))
	}
	
	required init?(coder: NSCoder) {
		fatalError("Storyboards are not supported")
	}
	
}
