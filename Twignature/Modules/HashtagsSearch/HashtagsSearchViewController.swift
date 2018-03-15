//
//  HastagsSearchViewController.swift
//  Twignature
//
//  Created by mac on 14.11.2017.
//  Copyright (c) 2017 Applikey. All rights reserved.
//

import UIKit

class HashtagsSearchViewController: TweetsForUserViewController {
    //MARK: - Properties
    @IBOutlet fileprivate weak var searchBar: DesignableTextField!
    @IBOutlet fileprivate weak var cancelSearchButton: UIButton!
    @IBOutlet fileprivate weak var textFieldContentViewHeightContstraint: NSLayoutConstraint!
    var text: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        configureInterface()
    }
    
    //MARK: - UI
    
    private func configureInterface() {
        localizeViews()
        tableView.contentInset = UIEdgeInsetsMake(textFieldContentViewHeightContstraint.constant, 0, 0, 0)
        searchBar.delegate = self
        searchBar?.text = text
    }
    
    private func localizeViews() {
    }

    func setupSearchText(_ text: String) {
        searchBar?.text = text
        self.text = text
    }
}

extension HashtagsSearchViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let searchText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
        (presenter as? HashtagsSearchPresenter)?.handleSearchInput(query: searchText)
        return true
    }
}