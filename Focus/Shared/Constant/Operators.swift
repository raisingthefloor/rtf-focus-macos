//
//  Operators.swift
//  D2D-Patient
//
//  Created by Vikas Suthar on 31/03/20.
//  Copyright © 2020 Plenar. All rights reserved.
//

import Foundation

public func > (lhs: Int?, rhs: Int?) -> Bool {
    let left = lhs ?? 0
    let right = rhs ?? 0

    return left > right
}

public func < (lhs: Int?, rhs: Int?) -> Bool {
    let left = lhs ?? 0
    let right = rhs ?? 0

    return left < right
}

public func >= (lhs: Int?, rhs: Int?) -> Bool {
    let left = lhs ?? 0
    let right = rhs ?? 0

    return left >= right
}

public func <= (lhs: Int?, rhs: Int?) -> Bool {
    let left = lhs ?? 0
    let right = rhs ?? 0

    return left <= right
}

precedencegroup PlusSpace {
    associativity: left
    higherThan: AdditionPrecedence
}

infix operator <+>: PlusSpace

public func <+> (lhs: String?, rhs: String?) -> String {
    let left = lhs ?? ""
    let right = rhs ?? ""

    return left + " " + right
}

infix operator <->: PlusSpace

public func <-> (lhs: String?, rhs: String?) -> String {
    let left = lhs ?? ""
    let right = rhs ?? ""

    return left + " - " + right
}

infix operator </>: PlusSpace

public func </> (lhs: String?, rhs: String?) -> String {
    let left = lhs ?? ""
    let right = rhs ?? ""

    return left + "\n" + right
}

infix operator ~~~: PlusSpace

public func ~~~ (lhs: String?, rhs: String?) -> String {
    let left = lhs ?? ""
    let right = rhs ?? ""

    return left <+> "(" + right + ")"
}

infix operator &/: MultiplicationPrecedence

public func &/ (lhs: Float, rhs: Float) -> Float {
    if rhs == 0 {
        return 0
    }
    return lhs / rhs
}

public func &/ (lhs: Int, rhs: Int) -> Int {
    if rhs == 0 {
        return 0
    }
    return lhs / rhs
}
