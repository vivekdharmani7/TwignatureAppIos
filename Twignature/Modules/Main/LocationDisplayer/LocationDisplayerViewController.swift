//
//  LocationDisplayerViewController.swift
//  Twignature
//
//  Created by mac on 29.09.2017.
//  Copyright (c) 2017 Applikey. All rights reserved.
//

import UIKit
import MapKit

class LocationDisplayerViewController: UIViewController {
    //MARK: - Properties
    var presenter:  LocationDisplayerPresenter!
	@IBOutlet private weak var mapView: MKMapView!
	
    //MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureInterface()
		presenter.viewIsReady()
    }
	
	//MARK: - Public
	func setupLocation(_ location: Location) {
		let annotation = MKPointAnnotation()
		let centerCoordinate = CLLocationCoordinate2D(latitude: location.latitude,
		                                              longitude: location.longitude)
		let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
		annotation.coordinate = centerCoordinate
		let region = MKCoordinateRegion(center: centerCoordinate, span: span)
		mapView.setRegion(region, animated: true)
		mapView.addAnnotation(annotation)
	}
    
    //MARK: - UI
    
    private func configureInterface() {
        localizeViews()
    }
    
    private func localizeViews() {
    }
	
	@IBAction private func backButtonPressed() {
		presenter.backAction()
	}
}
