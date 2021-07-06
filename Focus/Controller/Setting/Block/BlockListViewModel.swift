//
//  BlockListViewModel.swift
//  Focus
//
//  Created by Bhavi on 01/07/21.
//

import Cocoa
import Foundation
import L10n_swift
import RxRelay
import RxSwift

protocol BlockListViewModelIntput {
    func getBlockList() -> [BlockCategory]
}

protocol BlockListViewModelOutput: ActivityIndicatorProtocol {
    var onResult: PublishSubject<Result<Void, ErrorHandler>> { get set }
}

protocol BlockListViewModelType {
    var input: BlockListViewModelIntput { get }
    var output: BlockListViewModelOutput { get }
}

class BlockListViewModel: BlockListViewModelIntput, BlockListViewModelOutput, BlockListViewModelType {

    var onResult: PublishSubject<Result<Void, ErrorHandler>> = PublishSubject()

    var input: BlockListViewModelIntput { return self }
    var output: BlockListViewModelOutput { return self }
    var is_animating: BehaviorRelay<Bool> = BehaviorRelay(value: false)

    var bag = DisposeBag()

    let blockNames: [String] = ["Calls", "Notification (Turn DND on)", "Social Media", "Games", "News", "Shopping", "Projects", "Medical"]
    let childeren: [String] = ["Facebook", "Intagram", "LinkedIn"]


    func getBlockList() -> [BlockCategory] {
        var blockCategories: [BlockCategory] = []

        for i in 0 ..< blockNames.count {
            var childrenBlock: [BlockData] = []
            if (i % 2) != 0 {
                for i in 0 ..< childeren.count {
                    let block = BlockData(id: i, name: childeren[i])
                    childrenBlock.append(block)
                }
            }

            let block = BlockCategory(id: i, name: blockNames[i], childeren: childrenBlock)
            blockCategories.append(block)
        }
        return blockCategories
    }
}

struct BlockCategory {
    var id: Int?
    var name: String?
    var childeren: [BlockData?]
}

struct BlockData {
    var id: Int?
    var name: String?
}
