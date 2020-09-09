//
// The detail view shows details for a single bike rack.
// The displayed information includes a map showing the location, the name of the rack, the available bikes by type and the total capacity.
// The user can return to the list using the nav bar or by swiping right.
//

import UIKit
import MapKit

class RackDetailViewController: UIViewController {

	var mapView: MKMapView!
	var nameLabel: UILabel!
	
	var classicBikeHeadingLabel: UILabel!
	var electricBikeHeadingLabel: UILabel!
	var classicBikeImageView: UIImageView!
	var electricBikeImageView: UIImageView!
	var classicBikeCountLabel: UILabel!
	var electricBikeCountLabel: UILabel!
	
	var capacityLabel: UILabel!

	var topStackView: UIStackView!
	var detailStackView: UIStackView!
	var classicBikeStackView: UIStackView!
	var electricBikeStackView: UIStackView!
	
	var mapViewDimensionalConstraint: NSLayoutConstraint?
	
	var rack: Rack!
	
    override func viewDidLoad() {
		guard rack != nil else { fatalError("rack must be set before a RackDetailViewController is used") }
		
        super.viewDidLoad()
		
		view.backgroundColor = .systemBackground
		
		// Create all the value controls
		mapView = MKMapView()
		mapView.isScrollEnabled = false
		mapView.region = MKCoordinateRegion(center: rack.coordinate, latitudinalMeters: 400, longitudinalMeters: 400)
		let mapAnnotation = MKPointAnnotation()
		mapAnnotation.coordinate = CLLocationCoordinate2D(latitude: rack.coordinateLatitude, longitude: rack.coordinateLongitude)
		mapView.addAnnotation(mapAnnotation)

		nameLabel = UILabel()
		nameLabel.text = rack.name
		nameLabel.font = .preferredFont(forTextStyle: .title1)
		
		classicBikeHeadingLabel = UILabel()
		classicBikeHeadingLabel.text = NSLocalizedString("Classic Bikes", comment: "Detail view")
		classicBikeHeadingLabel.font = .preferredFont(forTextStyle: .body)
		classicBikeHeadingLabel.textColor = .secondaryLabel
		
		electricBikeHeadingLabel = UILabel()
		electricBikeHeadingLabel.text = NSLocalizedString("Electric Bikes", comment: "Detail view")
		electricBikeHeadingLabel.font = .preferredFont(forTextStyle: .body)
		electricBikeHeadingLabel.textColor = .secondaryLabel
		
		let bikeImage = UIImage(named: "Bike")!
		
		classicBikeImageView = UIImageView(image: bikeImage)
		classicBikeImageView.tintColor = .systemGreen
		// Scale properly for accessibility text sizes
		classicBikeImageView.widthAnchor.constraint(equalTo: classicBikeImageView.heightAnchor, multiplier: bikeImage.size.width / bikeImage.size.height).isActive = true

		electricBikeImageView = UIImageView(image: bikeImage)
		electricBikeImageView.tintColor = .systemTeal
		// Scale properly for accessibility text sizes
		electricBikeImageView.widthAnchor.constraint(equalTo: electricBikeImageView.heightAnchor, multiplier: bikeImage.size.width / bikeImage.size.height).isActive = true

		classicBikeCountLabel = UILabel()
		classicBikeCountLabel.text = String(rack.classicBikesAvailable)
		classicBikeCountLabel.font = .preferredFont(forTextStyle: .title3)
		
		electricBikeCountLabel = UILabel()
		electricBikeCountLabel.text = String(rack.electricBikesAvailable)
		electricBikeCountLabel.font = .preferredFont(forTextStyle: .title3)
		
		capacityLabel = UILabel()
		capacityLabel.text = String(format: NSLocalizedString("Capacity (formatted)", comment: "Detail view"), rack.emptySlots + rack.classicBikesAvailable + rack.electricBikesAvailable)
		capacityLabel.font = .preferredFont(forTextStyle: .footnote)
		
		// Layout using stack views
		
		// Both bike types get a stack view containing an icon and the count label
		classicBikeStackView = UIStackView(arrangedSubviews: [classicBikeImageView, classicBikeCountLabel])
		classicBikeStackView.spacing = 10
		electricBikeStackView = UIStackView(arrangedSubviews: [electricBikeImageView, electricBikeCountLabel])
		electricBikeStackView.spacing = 10
		
		// A low hugging value spacer will lay out the detail stack view nicely
		let spacer = UIView()
		spacer.setContentHuggingPriority(.defaultLow, for: .vertical)

		// The detail stack contains all the controls outside the map and is centered
		detailStackView = UIStackView(arrangedSubviews: [nameLabel, classicBikeHeadingLabel, classicBikeStackView, electricBikeHeadingLabel, electricBikeStackView, capacityLabel, spacer])
		detailStackView.axis = .vertical
		detailStackView.alignment = .center
		detailStackView.spacing = 20
		detailStackView.isLayoutMarginsRelativeArrangement = true
		
		detailStackView.setCustomSpacing(5, after: classicBikeHeadingLabel)
		detailStackView.setCustomSpacing(5, after: electricBikeHeadingLabel)
		detailStackView.layoutMargins = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)

		// The top level stack view lays out the map and the rest of the controls
		topStackView = UIStackView(arrangedSubviews: [mapView, detailStackView])
		topStackView.axis = .vertical
		topStackView.alignment = .fill
		topStackView.spacing = 10
		
		view.addSubview(topStackView)

		topStackView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)

		updateConstraints()
	}
	
	@objc func swipedToExit() {
		dismiss(animated: true, completion: nil)
	}
	
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)

		// Update the layout when the device is rotated
		updateConstraints()
	}
	
	// In portrait orientation, the map will be at the top 40% of the height, in landscape on the left 40% of the width
	func updateConstraints() {
		mapViewDimensionalConstraint?.isActive = false
		
		if UIDevice.current.orientation.isLandscape {
			topStackView.axis = .horizontal
			mapViewDimensionalConstraint = mapView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.4)
		} else {
			topStackView.axis = .vertical
			mapViewDimensionalConstraint = mapView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.4)
		}
		
		mapViewDimensionalConstraint?.isActive = true
	}

}
