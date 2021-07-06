//
//  MenuController.swift
//  Focus
//
//  Created by Bhavi on 16/06/21.
//

import Cocoa
import RxCocoa
import RxGesture
import RxSwift

class MenuController: BaseViewController {
    @IBOutlet var btnClose: NSButton!

    @IBOutlet var lblTitle: NSTextField!
    @IBOutlet var btnInfo: NSButton!

    @IBOutlet var checkBoxDND: NSButton!
    @IBOutlet var lblDnDInfo: NSTextField!

    @IBOutlet var checkBoxFocusTime: NSButton!
    @IBOutlet var txtBreakTime: NSTextField! // hide

    @IBOutlet var popBreakTime: NSPopUpButton!
    @IBOutlet var lblBrekInfo: NSTextField!

    @IBOutlet var txtFocusTime: NSTextField! // hide
    @IBOutlet var popFocusTime: NSPopUpButton!

    @IBOutlet var lblFocusInfo: NSTextField!
    @IBOutlet var lblFocusTInfo: NSTextField!

    @IBOutlet var checkBoxBlock: NSButton!
    @IBOutlet var lblBlockList: NSTextField!
//    @IBOutlet var comboBlock: NSComboBox!
    @IBOutlet var popBlock: NSPopUpButton!

    @IBOutlet var lblFocusLength: NSTextField!
    @IBOutlet var btn30m: NSButton!
    @IBOutlet var btn1Hr: NSButton!
    @IBOutlet var btn2Hr: NSButton!
    @IBOutlet var btnUntillI: NSButton!

    @IBOutlet var btnStop: NSButton!
    @IBOutlet var btnCostomizeSetting: NSButton!

    let viewModel: MenuViewModelType = MenuViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpText()
        setUpViews()
        bindData()
    }

    @IBAction func showInfoAction(_ sender: Any) {
        lblDnDInfo.isHidden = !lblDnDInfo.isHidden
        lblFocusTInfo.isHidden = !lblFocusTInfo.isHidden
    }
}

extension MenuController: BasicSetupType {
    func setUpText() {
        btnCostomizeSetting.title = "  Customize Setting".l10n()
        btnStop.title = FocusStopTime.stop_focus.title
        btn1Hr.title = FocusStopTime.one_hr.title
        btn2Hr.title = FocusStopTime.two_hr.title
        btn30m.title = FocusStopTime.half_past.title
        btnUntillI.title = FocusStopTime.untill_press_stop.title

        checkBoxDND.title = FocusOptions.dnd.title
        lblDnDInfo.stringValue = FocusOptions.dnd.information
        checkBoxFocusTime.title = FocusOptions.focus_break.title
        lblBrekInfo.stringValue = FocusOptions.focus_break_1.title
        lblFocusInfo.stringValue = FocusOptions.focus_break_2.title
        lblFocusTInfo.stringValue = FocusOptions.focus_break.information

        checkBoxBlock.title = FocusOptions.block_program_website.title
        lblBlockList.stringValue = FocusOptions.block_list.title

        lblFocusLength.stringValue = FocusOptions.block_program_website.information
    }

    func setUpViews() {
    }

    func bindData() {
//        viewModel.output.onResult.bind(onNext: { [weak self] result in
//            switch result {
//            case .success: break
//            case .failure: break
//            }
//        }).disposed(by: disposeBag)

        btnClose.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            NSApp.terminate(self)
        }).disposed(by: disposeBag)

        popBlock.menu = viewModel.input.getBlockList().0
        popFocusTime.menu = FocusTime.focustimes
        popBreakTime.menu = BreakTime.breaktimes

        checkBoxDND.rx.tap.subscribe(onNext: { [weak self] _ in
            print("DND")
            print(self?.checkBoxDND.state)
        }).disposed(by: disposeBag)

        checkBoxBlock.rx.tap.subscribe(onNext: { [weak self] _ in
            print("Block")
            print(self?.checkBoxBlock.state)
        }).disposed(by: disposeBag)

        checkBoxFocusTime.rx.tap.subscribe(onNext: { [weak self] _ in
            print("Focus time")
            print(self?.checkBoxFocusTime.state)
        }).disposed(by: disposeBag)

        btnCostomizeSetting.rx.tap.subscribe(onNext: { [weak self] _ in
            print("btnCostomizeSetting")
            self?.openCustomSetting()
        }).disposed(by: disposeBag)

        btn30m.rx.tap.subscribe(onNext: { [weak self] _ in
            print("30")
        }).disposed(by: disposeBag)

        btn1Hr.rx.tap.subscribe(onNext: { [weak self] _ in
            print("1 hr")
        }).disposed(by: disposeBag)

        btn2Hr.rx.tap.subscribe(onNext: { [weak self] _ in
            print("2 hr")
        }).disposed(by: disposeBag)

        btnUntillI.rx.tap.subscribe(onNext: { [weak self] _ in
            print("Untill")
        }).disposed(by: disposeBag)

        btnStop.rx.tap.subscribe(onNext: { [weak self] _ in
            print("Stop")
        }).disposed(by: disposeBag)
    }

    @IBAction func handleBlockSelection(_ sender: Any) {
        guard let popup = sender as? NSPopUpButton else { return }
        if popup.tag == -1 {
            print("Open Add Update View")
        }
        print("Selected block:", popBlock.titleOfSelectedItem ?? "")
    }

    @IBAction func foucsTimeSelection(_ sender: Any) {
        guard let popup = sender as? NSPopUpButton else { return }
        print("Selected Focus Time:", popup.titleOfSelectedItem ?? "")
    }

    @IBAction func breakTimeSelection(_ sender: Any) {
        guard let popup = sender as? NSPopUpButton else { return }
        print("Selected Break Time:", popup.titleOfSelectedItem ?? "")
    }

    func openCustomSetting() {
        if let vc = WindowsManager.getVC(withIdentifier: "sidCustomSetting", ofType: CustomSettingController.self, storyboard: "CustomSetting") {
            let animator = CustomAnimator()
            present(vc, animator: animator)
//            appDelegate?.customSetting?.showWindow(self)
        }
    }
}
