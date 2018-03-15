//
//  SettingsViewController.swift
//  Twignature
//
//  Created by mac on 12.10.2017.
//  Copyright (c) 2017 Applikey. All rights reserved.
//

import UIKit
import TTTAttributedLabel

class SettingsViewController: UIViewController {
    //MARK: - Properties
    var presenter: SettingsPresenter!
	var viewModel: SettingsViewModel?
	
	@IBOutlet private weak var tableView: UITableView!
	@IBOutlet private weak var profileImageView: UIImageView!
	@IBOutlet private weak var profileFullNameLabel: UILabel!
	@IBOutlet private weak var profileNameLabel: UILabel!
	
    //MARK: - Life cycle
	var sectionIsOpened:[SettingsViewModelSection: Bool] = [SettingsViewModelSection.about: false,
	                                                        SettingsViewModelSection.safety: false,
	                                                        SettingsViewModelSection.account: false]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureInterface()
		presenter.viewIsReady()
		tableView.rowHeight = UITableViewAutomaticDimension
		tableView.estimatedRowHeight = 240
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.setNavigationBarHidden(true, animated: false)
	}
    //MARK: - UI
    
    private func configureInterface() {
        localizeViews()
		tableView.delegate = self
		tableView.dataSource = self
		tableView.register(R.nib.expendingTableViewCell)
		tableView.register(R.nib.textFieldTableViewCell)
		tableView.register(R.nib.actionTableViewCell)
        tableView.register(R.nib.textViewTableViewCell)
        tableView.register(R.nib.actionSwitchTableViewCell)
    }
    
    private func localizeViews() {
    }
	
	//MARK: - IBAction
	@IBAction private func backButtonDidTap(_ sender: UIButton) {
		presenter.backButtonAction()
	}
	
	@IBAction private func doneButtonDidTap(_ sender: UIButton) {
		presenter.doneButtonAction()
	}
	//MARK: - Public
	
	func setupViewModel(_ viewModel: SettingsViewModel) {
		self.viewModel = viewModel
		self.tableView.reloadData()
		profileNameLabel.text = viewModel.screenName
		profileFullNameLabel.text = "@\(viewModel.name)"
		guard let path = viewModel.profileImageUrl else { return }
		profileImageView.kf.setImage(with: path)
	}
	
	@IBAction func mailDidTap(_ sender: Any) {
		presenter.mailAction()
	}
}

//MARK: UITableViewDelegate, UITableViewDataSource
extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return SettingsViewModelSection.countOfItems()
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let section = SettingsViewModelSection(rawValue: section) else {
			return 0
		}
		if sectionIsOpened[section] ?? false {
			return 1 + section.countOfItemsInSection()
		} else {
			return 1
		}
	}
	
	func tableView(_ tableView: UITableView,
	               cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let section = SettingsViewModelSection(rawValue: indexPath.section) else {
			return UITableViewCell()
		}
		if indexPath.row == 0 {
	
			guard let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.expendingTableViewCell, for: indexPath) else {
					return UITableViewCell()
			}
			cell.setTitle(section.title())
			cell.setStateAsExpended(sectionIsOpened[section] ?? false)
			return cell
		} else {
			guard let field = section.fieldForRow(rawValue: indexPath.row - 1) else {
				return UITableViewCell()
			}
			switch field.fieldType() {
			case .textField:
				let optionalCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.textFieldTableViewCell, for: indexPath)
				guard let cell = optionalCell else {
					return UITableViewCell()
				}
				cell.setTitle(field.title())
				cell.setFieldText("")
				guard let accountField = field as? SettingsViewModelAccount else {
						return cell
				}
				cell.didEndEditingHandler = { [weak self] (text) in
					self?.viewModel?.accoutSettings[accountField] = text
				}
				guard let setting = viewModel?.accoutSettings[accountField] as? String else {
					return cell
				}
				cell.setFieldText(setting)
				return cell
			case .textView:
				let optionalCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.textViewTableViewCell, for: indexPath)
				guard let cell = optionalCell else {
                    return UITableViewCell()
                }
                cell.setTitle(field.title())
                cell.setFieldText("")
                guard let accountField = field as? SettingsViewModelAccount else {
                    return cell
                }
                cell.didEndEditingHandler = { [weak self] (text) in
                    self?.viewModel?.accoutSettings[accountField] = text
                }
                guard let setting = viewModel?.accoutSettings[accountField] as? String else {
                    return cell
                }
                cell.setFieldText(setting)
                return cell
			case .action:
				guard let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.actionTableViewCell, for: indexPath) else {
					return UITableViewCell()
				}
				cell.setTitle(field.title())
				return cell
            case .actionSwitch:
				let optionalCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.actionSwitchTableViewCell, for: indexPath)
				guard let cell = optionalCell else {
                    return UITableViewCell()
                }
                cell.setTitle(field.title())
                cell.setFieldValue(false)
                guard let accountField = field as? SettingsViewModelAccount else {
                    return cell
                }
                cell.switchDidChangeValueHandler = { [weak self] (value) in
                    self?.viewModel?.accoutSettings[accountField] = value
                }
                guard let setting = viewModel?.accoutSettings[accountField] as? Bool else {
                    return cell
                }
                cell.setFieldValue(setting)
                return cell
			
			case .label:
				/*guard let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.linkableCell, for: indexPath) else {
					return UITableViewCell()
				}
				configureLinkableCell(cell: cell)
				return cell*/
				return UITableViewCell()
			case .none:
				return UITableViewCell()
			}
		}
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		guard let section = SettingsViewModelSection(rawValue: indexPath.section) else {
			return
		}
		if indexPath.row == 0 {
			if sectionIsOpened[section] ?? false {
				sectionIsOpened[section] = false
				var indexPathes:[IndexPath] = []
				for index in 0..<section.countOfItemsInSection() {
					let path = IndexPath(row: index + 1, section: indexPath.section)
					indexPathes.append(path)
				}
				tableView.beginUpdates()
				tableView.deleteRows(at: indexPathes, with: UITableViewRowAnimation.left)
				tableView.reloadRows(at: [indexPath], with: .none)
				tableView.endUpdates()
			} else {
				sectionIsOpened[section] = true
				var indexPathes:[IndexPath] = []
				for index in 0..<section.countOfItemsInSection() {
					let path = IndexPath(row: index + 1, section: indexPath.section)
					indexPathes.append(path)
				}
				tableView.beginUpdates()
				tableView.insertRows(at: indexPathes, with: UITableViewRowAnimation.left)
				tableView.reloadRows(at: [indexPath], with: .none)
				tableView.endUpdates()
			}
		} else {
			guard let field = section.fieldForRow(rawValue: indexPath.row - 1) else {
				return
			}
			presenter.actionForSectionItemI(section, item: field)
		}
	}
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		return UIView()
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 15
	}
}
