/*
 Copyright 2020 Raising the Floor - International

 Licensed under the New BSD license. You may not use this file except in
 compliance with this License.

 You may obtain a copy of the License at
 https://github.com/GPII/universal/blob/master/LICENSE.txt

 The R&D leading to these results received funding from the:
 * Rehabilitation Services Administration, US Dept. of Education under
   grant H421A150006 (APCP)
 * National Institute on Disability, Independent Living, and
   Rehabilitation Research (NIDILRR)
 * Administration for Independent Living & Dept. of Education under grants
   H133E080022 (RERC-IT) and H133E130028/90RE5003-01-00 (UIITA-RERC)
 * European Union's Seventh Framework Programme (FP7/2007-2013) grant
   agreement nos. 289016 (Cloud4all) and 610510 (Prosperity4All)
 * William and Flora Hewlett Foundation
 * Ontario Ministry of Research and Innovation
 * Canadian Foundation for Innovation
 * Adobe Foundation
 * Consumer Electronics Association Foundation
 */

import Cocoa

class BlockListViewC: BaseViewController {
    @IBOutlet var tblCategory: NSTableView!
    @IBOutlet var tblBlock: NSTableView!
    @IBOutlet var tblNotBlock: NSTableView!

    let viewModel: BlockListViewModelType = BlockListViewModel()
    var webSites: [String] = []

    let cellIdentifier: String = "checkboxCellID"
    let addCellIdentifier: String = "addCellID"

    override func setTitle() -> String { return SettingOptions.block_setting.title }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        setUpText()
        setUpViews()
        bindData()
        tableViewSetup()
    }
}

extension BlockListViewC: BasicSetupType {
    func setUpText() {
    }

    func setUpViews() {
    }

    func bindData() {
    }
}

extension BlockListViewC: NSTableViewDataSource, NSTableViewDelegate {
    func tableViewSetup() {
        tblCategory.delegate = self
        tblCategory.dataSource = self
        tblCategory.usesAutomaticRowHeights = true

        tblBlock.delegate = self
        tblBlock.dataSource = self
        tblBlock.usesAutomaticRowHeights = true

        tblNotBlock.delegate = self
        tblNotBlock.dataSource = self
        tblNotBlock.usesAutomaticRowHeights = true
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        return getCount(tableView: tableView)
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        return setupCellAsperTable(tableView: tableView, row: row)
    }

//    public func tableView(_ tableView: NSTableView, rowActionsForRow row: Int, edge: NSTableView.RowActionEdge) -> [NSTableViewRowAction] {
//        print("swipe")
//        // left swipe
//        if edge == .trailing {
//            let deleteAction = NSTableViewRowAction(style: .destructive, title: "Delete", handler: { _, row in
//                // action code
//                self.webSites.remove(at: row)
//                tableView.removeRows(at: IndexSet(integer: row), withAnimation: .effectFade)
//            })
//            deleteAction.backgroundColor = NSColor.red
//            return [deleteAction]
//        }
//        return []
//    }

    func setupCellAsperTable(tableView: NSTableView, row: Int) -> NSView? {
        if tableView == tblCategory {
            let blocks = viewModel.input.getBlockList()
            let item = blocks[row]

            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? CheckBoxCell {
                cell.checkBox.title = item.name ?? "-"

                cell.checkBox.rx.tap.subscribe(onNext: { [weak self] _ in
                    print("Block")
                    print(cell.checkBox.state)
                }).disposed(by: cell.disposeBag)

                return cell
            }

        } else if tableView == tblBlock {
            if row == 0 {
                if let buttonCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: addCellIdentifier), owner: nil) as? ButtonCell {
                    
                    buttonCell.configBlockCell()
                    buttonCell.btnAddApp.rx.tap.subscribe(onNext: { [weak self] _ in
                        print("btnAddApp")
                    }).disposed(by: buttonCell.disposeBag)

                    buttonCell.btnAddWeb.rx.tap.subscribe(onNext: { [weak self] _ in
                        self?.openPopup()
                    }).disposed(by: buttonCell.disposeBag)

                    return buttonCell
                }
            }
            let item = webSites[row - 1]

            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? CheckBoxCell {
                cell.checkBox.title = item

                cell.checkBox.rx.tap.subscribe(onNext: { [weak self] _ in
                    print("Block")
                    print(cell.checkBox.state)
                }).disposed(by: cell.disposeBag)

                return cell
            }

        } else if tableView == tblNotBlock {
            if row == 0 {
                if let buttonCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: addCellIdentifier), owner: nil) as? ButtonCell {
                    
                    buttonCell.configBlockCell()
                    buttonCell.btnAddApp.rx.tap.subscribe(onNext: { [weak self] _ in
                        print("btnAddApp")
                    }).disposed(by: buttonCell.disposeBag)

                    buttonCell.btnAddWeb.rx.tap.subscribe(onNext: { [weak self] _ in
                        self?.openPopup()
                    }).disposed(by: buttonCell.disposeBag)

                    return buttonCell
                }
            }

            let item = webSites[row - 1]

            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: addCellIdentifier), owner: nil) as? CheckBoxCell {
                cell.checkBox.title = item

                cell.checkBox.rx.tap.subscribe(onNext: { [weak self] _ in
                    print("Block")
                    print(cell.checkBox.state)
                }).disposed(by: cell.disposeBag)

                return cell
            }
        }

        return nil
    }

    func getCount(tableView: NSTableView) -> Int {
        if tableView == tblCategory {
            return viewModel.input.getBlockList().count
        } else if tableView == tblBlock {
            return webSites.count + 1
        } else if tableView == tblNotBlock {
            return webSites.count + 1
        }

        return 0
    }

    func listofApps() {
        let workspace = NSWorkspace.shared
        let apps = workspace.runningApplications.filter { $0.activationPolicy == .regular }
        print(apps)
    }

    func openPopup() {
        promptToForInput("Enter Web Url", "Copy Url from Webrowser and paste it below.", completion: { (value: String, action: Bool) in
            if action {
                print(value)
                webSites.append(value)
                tblBlock.reloadData()
                tblNotBlock.reloadData()
            }
        })
    }
}
