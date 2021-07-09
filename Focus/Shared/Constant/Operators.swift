/* Copyright 2020 Raising the Floor - International

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
