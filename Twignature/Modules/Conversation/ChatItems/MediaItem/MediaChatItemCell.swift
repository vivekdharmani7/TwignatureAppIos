import UIKit
import Chatto
import AVFoundation

class MediaChatItemCell: UICollectionViewCell {

	@IBOutlet weak var background: UIView!
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet var leadingConstraint: NSLayoutConstraint!
	@IBOutlet var trailingConstraint: NSLayoutConstraint!
	@IBOutlet weak var widthConstraint: NSLayoutConstraint!
	static let defaultWidth: CGFloat = 50
	
	func configureWith(model: MediaChatItemModel) {
		let currentUserMessage = model.senderId == Session.current?.user.id
		trailingConstraint.isActive = currentUserMessage
		leadingConstraint.isActive = !currentUserMessage
		widthConstraint.constant = MediaChatItemCell.defaultWidth
		background.backgroundColor = currentUserMessage ? ChatColors.outgoingColor : ChatColors.incomingColor
		guard let url = model.mediaItem.mediaUrl else {
			return
		}
		self.imageView.setTwitterPrivateImage(with: url) { [weak self] in
			guard let imageView = self?.imageView, let image = imageView.image else { return }
			let rect = CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: imageView.frame.height)
			let imageFrame = AVMakeRect(aspectRatio: image.size, insideRect: rect)
			self?.widthConstraint.constant = imageFrame.width
		}
	}
}
