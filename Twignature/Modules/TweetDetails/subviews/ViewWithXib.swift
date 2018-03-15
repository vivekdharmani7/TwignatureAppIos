import UIKit

class ViewWithXib: UIView {

	func initUI() {}

	fileprivate func xibSetup() {
		let view = loadViewFromNib()
		view.frame = bounds
		view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
		addSubview(view)
		initUI()
	}

	private func loadViewFromNib() -> UIView {
		let nibName = String(describing: type(of: self))
		let bundle = Bundle(for: self.classForCoder)
		let nib = UINib(nibName: nibName, bundle: bundle)
		
		guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else {
			assert(false, "No xib with name \(nibName)")
			return UIView()
		}
		return view
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		xibSetup()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		xibSetup()
	}

}
