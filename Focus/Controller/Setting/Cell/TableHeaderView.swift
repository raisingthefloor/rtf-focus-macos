//
//  TableHeaderView.swift
//  Focus
//
//  Created by Bhavi on 01/07/21.
//

import Cocoa
import RxCocoa
import RxGesture
import RxSwift

class TableHeaderView: NSView, LoadableView {
    var mainView: NSView?

    @IBOutlet var lblTitle: NSTextField!
    @IBOutlet var btnAddApp: NSButton!
    @IBOutlet var btnAddWebSite: NSButton!

    var disposeBag = DisposeBag()

    init() {
        super.init(frame: NSRect.zero)
        _ = load(fromNIBNamed: "TableHeaderView")
        setUpText()
        setUpViews()
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
}

extension TableHeaderView: BasicSetupType {
    func setUpText() {
        lblTitle.stringValue = "Also Block These".l10n()
        btnAddApp.title = "Add App".l10n()
        btnAddWebSite.title = "Add Website".l10n()
    }

    func setUpViews() {
    }
}
