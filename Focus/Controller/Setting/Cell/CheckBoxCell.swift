//
//  CheckBoxCell.swift
//  Focus
//
//  Created by Bhavi on 01/07/21.
//

import Cocoa
import RxCocoa
import RxGesture
import RxSwift

class CheckBoxCell: NSTableCellView {
    @IBOutlet var checkBox: NSButton!
    @IBOutlet var btnDelete: NSButton!


    var disposeBag = DisposeBag()

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
}
