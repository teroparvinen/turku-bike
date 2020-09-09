//
// The rack list view shows a list of all available bike racks.
// The list will be sorted by distance from the user's device if location access is granted. Otherwise, the racks will be ordered alphabetically.
// An error message will be displayed if the data could not be fetched, if there was an error parsing the data or if an unseen error occurred.
// The data can be refreshed by using pull to refresh or a navigation bar item.
//

import UIKit
import Combine
import CoreLocation

class RackTableViewController: UITableViewController {

	// The state of the list is represented by a state variable
	enum State {
		case uninitialized
		case initializing
		case requestFailed(BikeRackRequest.RequestError)
		case racksFetched([Rack])
		case racksFetchedWithLocation([Rack], CLLocationCoordinate2D)
	}

	enum Section {
		case main
	}

	// There are two possible cell types, represented by a data source item
	enum Item: Hashable {
		case rack(Rack)
		case error(String)
	}
	
	// Local typealiases to refer to typed data source
	typealias DataSource = UITableViewDiffableDataSource<Section, Item>
	typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
	
	var dataSource: DataSource!
	
	var dataSubscription: AnyCancellable?
	var locationSubscription: AnyCancellable?
	
	var currentState: State = .uninitialized
	
	init() {
		super.init(nibName: nil, bundle: nil)

		// Set navigation bar properties
		navigationItem.title = NSLocalizedString("Bike Racks", comment: "List page navigation item title")
		
		// Adding an empty UIView as the table footer prevents empty placeholder cells at the end of the list
		tableView.tableFooterView = UIView()
		
		// Register the cell classes
		tableView.register(RackTableViewCell.self, forCellReuseIdentifier: "RackCell")
		tableView.register(ErrorTableViewCell.self, forCellReuseIdentifier: "ErrorCell")
		
		// Add a navigation bar item to reload the list
		navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.counterclockwise"), style: .plain, target: self, action: #selector(refreshNaviItemTapped(_:)))
	}
	
	required init?(coder: NSCoder) {
		fatalError("Storyboards are not supported")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()

		// Create the diffable data source
		dataSource = DataSource(tableView: tableView) { tableView, indexPath, item in
			switch item {
			case .rack(let rack):
				let rackCell = tableView.dequeueReusableCell(withIdentifier: "RackCell", for: indexPath) as! RackTableViewCell
				
				rackCell.rack = rack
				
				return rackCell
			case .error(let errorDescription):
				let errorCell = tableView.dequeueReusableCell(withIdentifier: "ErrorCell", for: indexPath) as! ErrorTableViewCell
				
				errorCell.errorDescription = errorDescription
				errorCell.reloadCallback = {
					self.refreshData()
					self.applyState(.initializing)
				}
				
				return errorCell
			}
		}
		
		// Support pull to refresh
		refreshControl = UIRefreshControl()
		refreshControl?.addTarget(self, action: #selector(pulledToRefresh), for: .valueChanged)
		refreshControl?.attributedTitle = NSAttributedString(string: NSLocalizedString("Pull to refresh", comment: "List page"))

		// Start monitoring location. Triggering this here will also cause values to be published to the cells.
		LocationSource.shared.start()
		
		// Monitor location and update list ordering
		locationSubscription = LocationSource.shared.publisher.sink(receiveCompletion: { completion in
			LocationSource.shared.stop()
			self.locationSubscription = nil
		}, receiveValue: { coordinate in
			if let coordinate = coordinate {
				// Make sure location updates are applied in the main thread
				DispatchQueue.main.async {
					switch self.currentState {
					case .racksFetched(let racks), .racksFetchedWithLocation(let racks, _):
						self.applyState(.racksFetchedWithLocation(racks, coordinate))
					default:
						break
					}
				}
			}
		})
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		// If the view appeared for the first time, start loading data
		if case .uninitialized = currentState {
			refreshDataWithAlert()
			
			// Update state to prevent recurring loads, e.g. when moving between the list and detail view
			applyState(.initializing)
		}
	}
	
	@objc func pulledToRefresh(_ sender: UIRefreshControl) {
		refreshData {
			DispatchQueue.main.async {
				sender.endRefreshing()
			}
		}
	}
	
	@objc func refreshNaviItemTapped(_ sender: Any) {
		refreshDataWithAlert()
	}
	
	// Show a progress indicator in an alert controller when first loading data and when the navigation bar item is tapped
	func refreshDataWithAlert() {
		let activityAlert = UIAlertController(title: nil, message: NSLocalizedString("Updating data", comment: "List page"), preferredStyle: .alert)
		let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
		loadingIndicator.hidesWhenStopped = true
		loadingIndicator.style = .medium
		loadingIndicator.startAnimating()
		activityAlert.view.addSubview(loadingIndicator)
		present(activityAlert, animated: true, completion: nil)
		
		refreshData {
			DispatchQueue.main.async {
				activityAlert.dismiss(animated: false, completion: nil)
			}
		}
	}
	
	func refreshData(completionCallback: (() -> ())? = nil) {
		dataSubscription = BikeRackRequest.fetchAndParse().sink(receiveCompletion: { completion in
			// Handle errors to update the user interface
			if case let .failure(error) = completion {
				// Make sure network updates are applied in the main thread
				DispatchQueue.main.async {
					self.applyState(.requestFailed(error))
				}
			}
			
			completionCallback?()
		}) { response in
			// Make sure network updates are applied in the main thread
			DispatchQueue.main.async {
				self.applyState(.racksFetched(Array(response.racks.values)))
			}
		}
	}
	
	func applyState(_ state: State) {
		currentState = state

		// Apply to table view data source
		var snapshot = Snapshot()
		snapshot.appendSections([.main])

		switch state {
		case .racksFetched(let racks):
			// Apply racks to list in ascending alphabetical order based on name
			let items = racks
				.sorted { $0.name < $1.name }
				.map { Item.rack($0) }
			snapshot.appendItems(items, toSection: .main)
		case .racksFetchedWithLocation(let racks, let coordinate):
			// Apply racks to list in ascending order based on distance to device
			let items = racks
				.sorted { a, b in
					return a.coordinate.distance(to: coordinate) < b.coordinate.distance(to: coordinate)
				}
				.map { Item.rack($0) }
			snapshot.appendItems(items, toSection: .main)
		case .requestFailed(let error):
			snapshot.appendItems([.error(error.userDescription)], toSection: .main)
		default:
			break
		}

		self.dataSource.apply(snapshot, animatingDifferences: true, completion: nil)
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if let item = dataSource.itemIdentifier(for: indexPath), case let .rack(rack) = item {
			let detailViewController = RackDetailViewController()
			detailViewController.rack = rack
			
			navigationController?.pushViewController(detailViewController, animated: true)
		}
	}


}

