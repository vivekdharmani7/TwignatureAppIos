//
//  ConversationViewController.swift
//  Twignature
//
//  Created by Pavel Yevtukhov on 9/29/17.
//  Copyright (c) 2017 Applikey. All rights reserved.
//

import Chatto
import ChattoAdditions
import IQKeyboardManagerSwift

struct ChatColors {
	static let incomingColor = UIColor.bma_color(rgb: 0xE6ECF2)
	static let outgoingColor: UIColor = #colorLiteral(red: 0, green: 0.7647058824, blue: 1, alpha: 1)
}

class ConversationViewController: BaseChatViewController {
	
	var presenter:  ConversationPresenter!
	var avatarURL: URL? {
		didSet {
			avatarView?.imageView.setImage(with: avatarURL)
		}
	}
	
	var chatInputPresenter: BasicChatInputBarPresenter!
	weak var datasource: ChatDataSourceProtocol?
	weak var delegate: ChatDataSourceDelegateProtocol?
	private weak var avatarView: AvatarContainerView?
	fileprivate weak var chatInputView: ChatInputView!
	
	func setMessageText(_ text: String?) {
		self.chatInputView.setText(text ?? "")
	}
	
	func setMessageImage(_ image: UIImage?) {
		chatInputView.setImage(image)
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
        configureInterface()
		chatItemsDecorator = TNChatItemsDecorator()
		presenter.viewIsReady()
    }
	
	private var kbManagerInitialState = false {
		didSet {
			debugPrint("kbManagerInitialState \(kbManagerInitialState)")
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		kbManagerInitialState = IQKeyboardManager.sharedManager().enable
		IQKeyboardManager.sharedManager().enable = false
		presenter.viewWillAppear()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		presenter.viewWillDisapear()
		IQKeyboardManager.sharedManager().enable = kbManagerInitialState
	}
	
    //MARK: - UI
    
    private func configureInterface() {
		configureNavBar()
    }
	
	private func configureNavBar() {
		let leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_back"),
		                                        style: UIBarButtonItemStyle.plain,
		                                        target: self,
		                                        action: #selector(backDidClick))
		
		navigationItem.leftBarButtonItem = leftBarButtonItem
		
		let avatarView = AvatarContainerView()
		let navBarHeight = navigationController?.navigationBar.intrinsicContentSize.height ?? 44
		let avatarHeight = navBarHeight - 4
		avatarView.frame.size = CGSize(width: avatarHeight, height: avatarHeight)
		navigationItem.titleView = avatarView
		self.avatarView = avatarView
	}
	
	dynamic
	private func backDidClick() {
		presenter.backAction()
	}
	
	private func getTextBuilder() -> ChatItemPresenterBuilderProtocol {
		let viewModelBuilder = TextMessageViewModelDefaultBuilder<TNChatItem>()
		let interactionHandler = self
		typealias BuilderType = TextMessageViewModelDefaultBuilder<TNChatItem>
		let textMessagePresenterBuilder = TextMessagePresenterBuilder<BuilderType, ConversationViewController>(
			viewModelBuilder: viewModelBuilder,
			interactionHandler: interactionHandler
		)
		let colors = BaseMessageCollectionViewCellDefaultStyle.Colors(incoming: ChatColors.incomingColor, outgoing: ChatColors.outgoingColor)
		let style = BaseMessageCollectionViewCellDefaultStyle(colors: colors)
		let textCellStyle: TextMessageCollectionViewCellDefaultStyle = TextMessageCollectionViewCellDefaultStyle(
			baseStyle: style)
		
		textMessagePresenterBuilder.textCellStyle = textCellStyle
		textMessagePresenterBuilder.baseMessageStyle = style
		
		return textMessagePresenterBuilder
	}
	
	override func createPresenterBuilders() -> [ChatItemType: [ChatItemPresenterBuilderProtocol]] {
		return [
			TNChatItem.typeName: [getTextBuilder()],
			MediaChatItemModel.chatItemType: [MediaChatItemPresenterBuilder()]
		]
	}
	
	override func createChatInputView() -> UIView {
		let chatInputView = ChatInputView.nibView()!
		chatInputView.translatesAutoresizingMaskIntoConstraints = false
		chatInputView.maxCharactersCount = UInt(AppDefined.maxTweetLettersNumber)
		chatInputView.delegate = self
		self.chatInputView = chatInputView
		return chatInputView
	}
}

extension ConversationViewController : BaseMessageInteractionHandlerProtocol {
	func userDidTapOnFailIcon(viewModel: TextMessageViewModel<TNChatItem>, failIconView: UIView) {
		
	}
	
	func userDidTapOnAvatar(viewModel: TextMessageViewModel<TNChatItem>) {
		
	}
	
	func userDidTapOnBubble(viewModel: TextMessageViewModel<TNChatItem>) {
		
	}
	
	func userDidBeginLongPressOnBubble(viewModel: TextMessageViewModel<TNChatItem>) {
		
	}
	
	func userDidEndLongPressOnBubble(viewModel: TextMessageViewModel<TNChatItem>) {
		
	}
}

extension ConversationViewController: ChatInputViewDelegate {
	func editDidFinish(text: String) {
		view.endEditing(true)
		chatInputView.setText("")
		chatInputView.setImage(nil)
		presenter.sendMessageAction(text)
		
	}
	
	func pickImageAction() {
		presenter.pickImageAction()
	}
}
