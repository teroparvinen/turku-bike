//
// Extend UIView with a convenience method for easier and less verbose programmatic initialization when creating constraints
//

import UIKit

public extension UIView {
	
	struct AnchorConstraints {
		let top: NSLayoutConstraint?
		let left: NSLayoutConstraint?
		let bottom: NSLayoutConstraint?
		let right: NSLayoutConstraint?
	}
	
	@discardableResult
	func anchor(top: NSLayoutYAxisAnchor?, left: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, right: NSLayoutXAxisAnchor?, insets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)) -> AnchorConstraints {
		translatesAutoresizingMaskIntoConstraints = false
		
		var topConstraint: NSLayoutConstraint?
		var leftConstraint: NSLayoutConstraint?
		var bottomConstraint: NSLayoutConstraint?
		var rightConstraint: NSLayoutConstraint?
		
		if let top = top {
			topConstraint = topAnchor.constraint(equalTo: top, constant: insets.top)
			topConstraint!.isActive = true
		}
		if let left = left {
			leftConstraint = leftAnchor.constraint(equalTo: left, constant: insets.left)
			leftConstraint!.isActive = true
		}
		if let bottom = bottom {
			bottomConstraint = bottom.constraint(equalTo: bottomAnchor, constant: insets.bottom)
			bottomConstraint!.isActive = true
		}
		if let right = right {
			rightConstraint = right.constraint(equalTo: rightAnchor, constant: insets.right)
			rightConstraint!.isActive = true
		}

		return AnchorConstraints(top: topConstraint, left: leftConstraint, bottom: bottomConstraint, right: rightConstraint)
	}
	
}
