import UIKit
import Chatto

public class MediaChatItemPresenterBuilder: ChatItemPresenterBuilderProtocol {

    public func canHandleChatItem(_ chatItem: ChatItemProtocol) -> Bool {
        return chatItem is MediaChatItemModel
    }

    public func createPresenterWithChatItem(_ chatItem: ChatItemProtocol) -> ChatItemPresenterProtocol {
        assert(self.canHandleChatItem(chatItem))
		guard let chatItem = chatItem as? MediaChatItemModel else {
			assert(false)
			return BaseChatItemPresenter()
		}
        return MediaChatItemPresenter(timeSeparatorModel: chatItem)
    }

    public var presenterType: ChatItemPresenterProtocol.Type {
        return MediaChatItemPresenter.self
    }
}

class MediaChatItemPresenter: ChatItemPresenterProtocol {

    let cellViewModel: MediaChatItemModel
	
    init (timeSeparatorModel: MediaChatItemModel) {
        self.cellViewModel = timeSeparatorModel
    }

    private static let cellReuseIdentifier = String(describing: MediaChatItemCell.self)

    static func registerCells(_ collectionView: UICollectionView) {
		collectionView.register(R.nib.mediaChatItemCell)
    }

    func dequeueCell(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: MediaChatItemPresenter.cellReuseIdentifier, for: indexPath)
    }

    func configureCell(_ cell: UICollectionViewCell, decorationAttributes: ChatItemDecorationAttributesProtocol?) {
        guard let timeSeparatorCell = cell as? MediaChatItemCell else {
            assert(false, "expecting status cell")
            return
        }

    	timeSeparatorCell.configureWith(model: cellViewModel)
    }

    var canCalculateHeightInBackground: Bool {
        return true
    }

    func heightForCell(maximumWidth width: CGFloat, decorationAttributes: ChatItemDecorationAttributesProtocol?) -> CGFloat {
        return 200
    }
}
