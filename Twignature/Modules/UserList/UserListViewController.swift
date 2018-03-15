//
//  UserListViewController.swift
//  Twignature
//
//  Created by Ivan Hahanov on 10/11/17.
//  Copyright (c) 2017 Applikey. All rights reserved.
//

import UIKit

class UserListViewController: UIViewController {
    //MARK: - Properties
    var presenter:  UserListPresenter!
    
	fileprivate(set) var users: [UserViewModel] = [] {
		didSet {
			nodataLabel.isHidden = !users.isEmpty
		}
	}
    
	@IBOutlet weak var nodataLabel: UILabel!
	@IBOutlet fileprivate weak var avatarView: AvatarContainerView!
    @IBOutlet fileprivate weak var tableView: UITableView!
    fileprivate var infiniteScroll: InfiniteScroll!
    
    var hidesCellButton: Bool = true
	var cellRightSideButtonTitle: String = R.string.profile.unfollow()
    
    //MARK: - Life cycle
	
	var textForNodata: String? {
		didSet {
			nodataLabel.text = textForNodata
		}
	}
	
    deinit {
        infiniteScroll.remove()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureInterface()
        presenter.viewIsReady()
    }
    
    //MARK: - UI
    
    private func configureInterface() {
        localizeViews()
        configureTableView()
    }
    
    private func configureTableView() {
        tableView.register(R.nib.userCell)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.pullToRefresh.add(target: self, action: #selector(didPullToRefresh))
        infiniteScroll = InfiniteScroll(tableView: tableView)
        infiniteScroll.shouldShowSpinner = { [unowned self] in
            return self.presenter.shouldInfiniteScroll()
        }
        infiniteScroll.action = { [unowned self] in
            self.presenter.handleScrollToBottom()
        }
    }
    
    private func localizeViews() {
    }
    
    // MARK: - Public
    
    func hideHUD() {
        super.hideHUD()
        tableView.pullToRefresh.end()
    }
    
    func set(avatar: URL?) {
        avatarView.imageView.setImage(with: avatar)
    }
    
    func endInfiniteScroll() {
        infiniteScroll.end()
    }
    
    func removeUser(id: TwitterId) {
        guard let index = users.index(where: { $0.id == id }) else { return }
        users.remove(at: index)
        tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .left)
    }
    
    func reload(users: [UserViewModel]) {
        self.users = users
        tableView.reloadData()
    }
    
    func append(users: [UserViewModel]) {
        let indexPaths = users.enumerated().map { IndexPath(row: $0.offset + users.count, section: 0) }
        self.users += users
        tableView.beginUpdates()
        tableView.insertRows(at: indexPaths, with: .bottom)
        tableView.endUpdates()
    }
    
    // MARK: - Actions
    
    @objc
    private func didPullToRefresh() {
        presenter.handlePullToRefresh()
    }
    
    // MARK: - IBActions
    
    @IBAction func didPressBack(_ sender: Any) {
        presenter.handleBack()
    }
}

extension UserListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.userCell, for: indexPath)!
        let user = users[indexPath.row]
        cell.hidesButton = hidesCellButton
        cell.button.setTitle(cellRightSideButtonTitle, for: .normal)
        cell.avatarView.imageView.setImage(with: user.avatarUrl)
        cell.nameLabel.text = user.name
        cell.screenNameLabel.text = user.screenName
        cell.action = user.buttonCallback
        if user.isVerified {
            cell.screenNameLabel.add(image: #imageLiteral(resourceName: "ic_verified"))
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
}

extension UserListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        users[indexPath.row].selectionClosure?()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 78
    }
}
