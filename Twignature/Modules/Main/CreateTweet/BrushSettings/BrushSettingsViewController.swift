//
//  BrushSettingsViewController.swift
//  Twignature
//
//  Created by mac on 28.11.2017.
//  Copyright (c) 2017 Applikey. All rights reserved.
//

import UIKit
import UIColor_Hex_Swift

class BrushSettingsViewController: UIViewController  {

    //MARK: - Properties
    @IBOutlet fileprivate weak var colorsPickerCollectionView: UICollectionView!
    @IBOutlet fileprivate weak var brushSizePickerCollectionView: UICollectionView!
    @IBOutlet fileprivate weak var colorPickerContainerView: UIView!
	@IBOutlet fileprivate weak var brightnessContainerView: UIView!
    @IBOutlet fileprivate(set) weak var hexColorTextField: UITextField!

	fileprivate(set) weak var colorCircleView: ColorWheel!
	fileprivate(set) weak var brightnessPicker: BrightnessView!
	var colors: [String] = []
	var sizes: [CGFloat] = []
	var selectedSize: CGFloat = 0 {
		didSet {
			brushSizePickerCollectionView.reloadData()
		}
	}

    var presenter:  BrushSettingsPresenter!
    
    //MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureInterface()
    }
    
    //MARK: - UI
	override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		return UIDevice.current.userInterfaceIdiom != .pad ? .allButUpsideDown : .portrait
	}

	private func configureInterface() {
        localizeViews()
	    configureCollectionViews()
	    configureHSVPicker()
	    self.presenter.viewIsReady()
    }
    
    private func localizeViews() {
    }

	private func configureCollectionViews() {
		colorsPickerCollectionView.delegate = self
		colorsPickerCollectionView.dataSource = self
		brushSizePickerCollectionView.delegate = self
		brushSizePickerCollectionView.dataSource = self
	}

	private func configureHSVPicker() {
		let circleColorView = ColorWheel(frame: self.colorPickerContainerView.bounds, color: .red)
		self.colorPickerContainerView.addSubview(circleColorView)
		self.colorCircleView = circleColorView

		let brightnessColorView = BrightnessView(frame: self.brightnessContainerView.bounds, color: .red)
		let image = R.image.rectangle_11()!
		brightnessColorView.setIndicatorImage(image)
		self.brightnessContainerView.addSubview(brightnessColorView)
		self.brightnessPicker = brightnessColorView
	}

	private func updateIndicatorPosition(color: UIColor) {
		let point = self.colorCircleView.pointForColor(color)
		self.colorCircleView.point = point
	}

	//MARK: - IBOutlets

	@IBAction private func saveToStorage(_ sender: Any) {
		presenter.saveToStorageAction()
	}

	//MARK: - Action

	public func configurePickerWithColor(_ color: UIColor, _ needToChangePlace: Bool) {
		self.colorCircleView.color = color
		if needToChangePlace {
			updateIndicatorPosition(color: color)
		}
		self.colorCircleView.drawIndicator()
		self.brightnessPicker.setViewColor(color)
		self.hexColorTextField.text = "\(color.hexString(false))"
	}

	public func setColorsModel(_ colors: [String]) {
		self.colors = colors
		self.colorsPickerCollectionView.reloadData()
	}

	public func setSizesModel(_ sizes: [CGFloat]) {
		self.sizes = sizes
		self.brushSizePickerCollectionView.reloadData()
	}

}

extension BrushSettingsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
	    // simulates switch operator
	    if collectionView == colorsPickerCollectionView {
		    return colors.count
	    } else if collectionView == brushSizePickerCollectionView {
		    return sizes.count
	    }
	    fatalError("collection view should be related to one of this collection view outlets")
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
	    // simulates switch operator
	    if collectionView == colorsPickerCollectionView {
		    return cellForColor(collectionView, atIndexPath: indexPath)
	    } else if collectionView == brushSizePickerCollectionView {
		    return cellForBrush(collectionView, atIndexPath: indexPath)
	    }
	    fatalError("cell should be related to one of this collection view outlets")
    }

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		// simulates switch operator
		collectionView.deselectItem(at: indexPath, animated: true)
		let itemIndex: Int = indexPath.item
		if collectionView == colorsPickerCollectionView {
			self.presenter.selectedItemFromColors(onIndex: itemIndex)
		} else if collectionView == brushSizePickerCollectionView {
			self.presenter.selectedItemFromSizes(onIndex: itemIndex)
		}
	}

	func cellForColor(_ collectionView: UICollectionView, atIndexPath indexPath: IndexPath) -> UICollectionViewCell {
		let identifier = R.reuseIdentifier.colorCell.identifier
		let reusableCell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
		guard let cell = reusableCell as? ColorCell else {
			return UICollectionViewCell()
		}
		//configure cell
		let color = colors[indexPath.item]
		cell.setColor(UIColor(color, defaultColor: .black))
		return cell
	}

	func cellForBrush(_ collectionView: UICollectionView, atIndexPath indexPath: IndexPath) -> UICollectionViewCell {
		let identifier = R.reuseIdentifier.brushCell.identifier
		let reusableCell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
		guard let cell = reusableCell as? BrushCell else {
			return UICollectionViewCell()
		}
		//configure cell
		let size = sizes[indexPath.item]
		cell.setBrushRadius(size)
		cell.setBrushSelected(size == self.selectedSize)
		return cell
	}
}
