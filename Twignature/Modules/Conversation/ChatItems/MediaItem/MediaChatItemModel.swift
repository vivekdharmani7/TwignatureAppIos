import UIKit
import Chatto

class MediaChatItemModel: ChatItemProtocol {
    let uid: String
    let type: String = MediaChatItemModel.chatItemType
	var mediaItem: MediaItem
	let senderId: String
	
    static let chatItemType: ChatItemType = String(describing: MediaChatItemModel.self)
	
	init?(message: Message) {
		guard let mediaItem = message.media?.first else {
			return nil
		}
		self.uid = message.id
		self.mediaItem = mediaItem
		self.senderId = message.sender.id
    }
}
