//
//  HeaderViewC.swift
//  Focus
//
//  Created by Bhavi on 29/06/21.
//

import Cocoa
import RxCocoa
import RxSwift


class HeaderViewC: NSViewController {
    
    @IBOutlet var headerView: NSView!
    @IBOutlet weak var stackView: NSStackView!
    @IBOutlet var headerTextField: NSTextField!
    @IBOutlet var showHideButton: NSButton!
    
    var disposeBag = DisposeBag()
    var disclose: (() -> Swift.Void)? // This state will be set by the stack item host.

    // MARK: - View Controller Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpText()
        setUpViews()
        bindData()
    }
}

extension HeaderViewC: BasicSetupType, StackItemHeader {
    func setUpText() {
        headerTextField.stringValue = title!
    }

    func setUpViews() {
        headerView.layer?.backgroundColor = .black        
    }

    func bindData() {
        showHideButton.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.disclose?()
        }).disposed(by: disposeBag)
    }

    // MARK: - StackItemHeader Procotol
    func update(toDisclosureState: NSControl.StateValue) {
        showHideButton.state = toDisclosureState
    }
}
