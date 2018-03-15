//
//  TNChatItemsDecorator.swift
//  Twignature
//
//  Created by Pavel Yevtukhov on 10/1/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import Chatto
import ChattoAdditions

final class TNChatItemsDecorator: ChatItemsDecoratorProtocol {
	
	func decorateItems(_ chatItems: [ChatItemProtocol]) -> [DecoratedChatItem] {
		let decoratedChatItems = chatItems.map({ (chatItem) -> DecoratedChatItem in
			let attr = ChatItemDecorationAttributes(bottomMargin: 20, showsTail: false, canShowAvatar: false)
			return DecoratedChatItem(chatItem: chatItem, decorationAttributes: attr)
		})
		
		return decoratedChatItems
	}
}
