//
//  ButtonCell.swift
//  Focus
//
//  Created by Bhavi on 01/07/21.
//

import Cocoa
import RxCocoa
import RxGesture
import RxSwift

class ButtonCell: NSTableCellView {
    @IBOutlet var btnAddApp: NSButton!
    @IBOutlet var BtnAddWeb: NSButton!

    var disposeBag = DisposeBag()

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        setUpText()
        setUpViews()
    }
}

extension ButtonCell: BasicSetupType {
    func setUpText() {
        btnAddApp.title = "Add App".l10n()
        BtnAddWeb.title = "Add Website".l10n()
    }

    func setUpViews() {
    }
}
