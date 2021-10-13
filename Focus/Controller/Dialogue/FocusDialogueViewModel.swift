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
import Foundation

protocol FocusDialogueViewModelIntput {
}

protocol FocusDialogueViewModelOutput {
}

protocol FocusDialogueViewModelType {
    var input: FocusDialogueViewModelIntput { get }
    var output: FocusDialogueViewModelOutput { get }
    var application: NSRunningApplication? { get set }
    var currentSession: (objFocus: Focuses?, objBl: Block_List?, apps: [Block_Interface], webs: [Block_Interface])? { get set }
    var reminderSchedule: Focus_Schedule? { get set }
}

class FocusDialogueViewModel: FocusDialogueViewModelIntput, FocusDialogueViewModelOutput, FocusDialogueViewModelType {
    var application: NSRunningApplication?
    var currentSession: (objFocus: Focuses?, objBl: Block_List?, apps: [Block_Interface], webs: [Block_Interface])?
    var reminderSchedule: Focus_Schedule?
    var input: FocusDialogueViewModelIntput { return self }
    var output: FocusDialogueViewModelOutput { return self }
}
