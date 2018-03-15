//
//  SettingsViewModel.swift
//  Twignature
//
//  Created by mac on 12.10.2017.
//  Copyright © 2017 Applikey. All rights reserved.
//

import Foundation

protocol ContainsCount {
	static func countOfItems() -> Int
}

protocol ContainsTitle {
	func title() -> String
}

protocol FieldType {
	func fieldType() -> SettingsViewModelFieldType
}

class SettingsViewModel {
	
	var accoutSettings: [SettingsViewModelAccount: Any]
	fileprivate(set) var name: String
	fileprivate(set) var screenName: String
	fileprivate(set) var profileImageUrl: URL?
    fileprivate(set) var shouldDisplaySensetiveContent: Bool?
	
	init(withAccount account: User) {
		accoutSettings = [:]
		accoutSettings[SettingsViewModelAccount.fullName] = account.name
		accoutSettings[SettingsViewModelAccount.url] = account.profileUrl?.description
		accoutSettings[SettingsViewModelAccount.location] = account.profileLocation
		accoutSettings[SettingsViewModelAccount.accountDescription] = account.description
		name = account.name
		screenName = account.screenName
		profileImageUrl = account.profileImageUrl
	}
    
    func setShouldDisplaySensetiveContent(_ value: Bool) {
        accoutSettings[SettingsViewModelAccount.sensetiveContent] = value
        shouldDisplaySensetiveContent = value
    }
}

//MARK: - GENERAL SECTION -
enum SettingsViewModelSection: Int, ContainsCount, ContainsTitle {
	
	case account = 0, safety, about, count
	
	static func countOfItems() -> Int {
		return SettingsViewModelSection.count.rawValue
	}
	
	func title() -> String {
		switch self {
		case .account:
			return "Account"
		case .safety:
			return "Safety"
		case .about:
			return "About"
//		case .contacts:
//			return "Contact us"
		case .count:
			return ""
		}
	}
	
	func fieldForRow(rawValue: Int) -> Field? {
		switch self {
		case .account:
			return SettingsViewModelAccount.create(rawValue: rawValue)
		case .safety:
			return SettingsViewModelSafety.create(rawValue: rawValue)
		case .about:
			return SettingsViewModelAbout.create(rawValue:rawValue)
//		case .contacts:
//			return SettingsViewModelContacts.create(rawValue:rawValue)
		case .count:
			return nil
		}
	}
	
	func countOfItemsInSection() -> Int {
		switch self {
		case .account:
			return SettingsViewModelAccount.countOfItems()
		case .safety:
			return SettingsViewModelSafety.countOfItems()
		case .about:
			return SettingsViewModelAbout.countOfItems()
//		case .contacts:
//			return SettingsViewModelContacts.countOfItems()
		case .count:
			return 0
		}
	}
}

//MARK: - SECTIONS -
protocol Field: ContainsCount, ContainsTitle, FieldType {
	static func create(rawValue: Int) -> Field?
}

enum SettingsViewModelAccount: Int, Field {
	case fullName = 0, url, location, accountDescription, sensetiveContent, count
	
	static func countOfItems() -> Int {
		return SettingsViewModelAccount.count.rawValue
	}
	
	static func create(rawValue: Int) -> Field? {
		return SettingsViewModelAccount(rawValue: rawValue)
	}
	
	func title() -> String {
		switch self {
		case .fullName:
			return "Full name"
		case .url:
			return "Url"
		case .location:
			return "Location"
		case .accountDescription:
			return "Description"
        case .sensetiveContent:
            return "Display sensitive media"
		case .count:
			return ""
		}
	}
	
	func fieldType() -> SettingsViewModelFieldType {
		switch self {
		case .fullName:
			return .textField
		case .url:
			return .textField
		case .location:
			return .textField
		case .accountDescription:
			return .textView
        case .sensetiveContent:
            return .actionSwitch
		case .count:
			return .none
		}
	}
}

enum SettingsViewModelSafety: Int, Field {
	case muttedList = 0, blockedList, twitterSettings, count
	
	static func countOfItems() -> Int {
		return SettingsViewModelSafety.count.rawValue
	}
	
	static func create(rawValue: Int) -> Field? {
		return SettingsViewModelSafety(rawValue: rawValue)
	}
	
	func title() -> String {
		switch self {
		case .muttedList:
			return "Muted"
		case .blockedList:
			return "Blocked"
        case .twitterSettings:
            return "Open twitter settings"
		case .count:
			return ""
		}
	}
	
	func fieldType() -> SettingsViewModelFieldType {
		switch self {
		case .blockedList:
			return .action
		case .muttedList:
			return .action
        case .twitterSettings:
            return .action
		case .count:
			return .none
		}
	}
}

enum SettingsViewModelAbout: Int, Field {
	case termsOfUse = 0, privacy, count
	
	static func countOfItems() -> Int {
		return SettingsViewModelAbout.count.rawValue
	}
	
	static func create(rawValue: Int) -> Field? {
		return SettingsViewModelAbout(rawValue: rawValue)
	}
	
	func title() -> String {
		switch self {
		case .termsOfUse:
			return "Terms of Use"
		case .privacy:
			return "Privacy"
		case .count:
			return ""
		}
	}
	
	func fieldType() -> SettingsViewModelFieldType {
		switch self {
		case .termsOfUse:
			return .action
		case .privacy:
			return .action
		case .count:
			return .none
		}
	}
}

struct SettingsViewModelContacts: Field {
	static func countOfItems() -> Int {
		return 1
	}
	
	static func create(rawValue: Int) -> Field? {
		return SettingsViewModelContacts()
	}
	
	func title() -> String {
		return "We always want to hear your thoughts. Please contact us with any recommendations or concerns about our service."
	}
	
	func fieldType() -> SettingsViewModelFieldType {
		return .label
	}
}

//MARK: - FIELDS -

enum SettingsViewModelFieldType {
	case textField
	case textView
	case action
    case actionSwitch
	case label
	case none
}
