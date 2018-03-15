//
//  DirectMessagePickerViewController.swift
//  Twignature
//
//  Created by Pavel Yevtukhov on 10/2/17.
//  Copyright (c) 2017 Applikey. All rights reserved.
//

import UIKit

class DirectMessagePickerViewController: BaseViewController {

	var presenter:  DirectMessagePickerPresenter!
	var users = [User]() {
		didSet {
			hideInprogress()
			tableView.reloadData()
		}
	}
	
	func hideInprogress() {
		tableView.es_stopLoadingMore()
		tableView.es_stopPullToRefresh()
		tableView.contentInset.bottom = 0
	}

	@IBOutlet private weak var tableView: UITableView!
	@IBOutlet private weak var searchBar: UISearchBar!
	
	override func viewDidLoad() {
        super.viewDidLoad()
        configureInterface()
		presenter.viewIsReady()
    }

    private func configureInterface() {
        configureTableView()
		searchBar.delegate = self
    }
	
	private func configureTableView() {
		tableView.register(R.nib.userCell)
		tableView.dataSource = self
		tableView.delegate = self
		tableView.es_addPullToRefresh { [weak self] in
			self?.presenter.refreshAction()
		}
		tableView.es_addInfiniteScrolling { [weak self] in
			self?.presenter.loadNextAction()
		}
	}
	
    private func localizeViews() {
    }

	@IBAction func closeDidClick(_ sender: Any) {
		presenter.closeAction()
	}
	
}

extension DirectMessagePickerViewController: UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return users.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.userCell.identifier) as? UserCell else {
			return UITableViewCell()
		}
		let user = users[indexPath.row]
        cell.hidesButton = true
		cell.avatarView.imageView.setImage(with: user.profileImageUrl)
		cell.nameLabel.text = user.name
		cell.screenNameLabel.text = user.screenName
		return cell
	}
}

extension DirectMessagePickerViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 64
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		presenter.userSelectAction(user: users[indexPath.row])
		tableView.deselectRow(at: indexPath, animated: true)
	}
}

extension DirectMessagePickerViewController: UISearchBarDelegate {
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		presenter.searchAction(searchTerm: searchText)
	}
}
