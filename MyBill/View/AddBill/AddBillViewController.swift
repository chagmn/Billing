//
//  AddBillViewController.swift
//  MyBill
//
//  Created by ChangMin on 2022/10/03.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit

protocol AddBillDelegate {
    func updateBillList()
}

final class AddBillViewController: UIViewController {
    var viewModel: AddBillViewModel
    var delegate: AddBillDelegate?
    let disposeBag = DisposeBag()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "사용한 금액을 입력해주세요."
        return label
    }()
    
    private lazy var titleInputBox: SettingBoxView = {
        let box = SettingBoxView(title: "제목", boxType: .text)
        return box
    }()
    
    private lazy var dateInputBox: SettingBoxView = {
        let box = SettingBoxView(title: "날짜", boxType: .date)
        return box
    }()
    
    private lazy var amountInputBox: SettingBoxView = {
        let box = SettingBoxView(title: "금액", boxType: .number)
        return box
    }()
    
    private lazy var memoInputBox: SettingBoxView = {
        let box = SettingBoxView(title: "메모", boxType: .text)
        return box
    }()
    
    private lazy var enterButton: CommonButtonView = {
        let button = CommonButtonView()
        button.setTitle("완료", for: .normal)
        return button
    }()
    
    init(viewModel: AddBillViewModel = AddBillViewModel()) {
        self.viewModel = viewModel
        self.viewModel.uuid = UIDevice.current.identifierForVendor!.uuidString
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bindViewModel()
    }
}

private extension AddBillViewController {
    func setupView() {
        self.view.backgroundColor = .white
        
        [titleLabel, titleInputBox, dateInputBox, amountInputBox, memoInputBox, enterButton]
            .forEach { self.view.addSubview($0) }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(36)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(20)
        }
        
        titleInputBox.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(50)
            $0.leading.trailing.equalToSuperview().inset(24)
        }
        
        dateInputBox.snp.makeConstraints {
            $0.top.equalTo(titleInputBox.snp.bottom).offset(20)
            $0.leading.trailing.equalTo(titleInputBox)
        }
        
        amountInputBox.snp.makeConstraints {
            $0.top.equalTo(dateInputBox.snp.bottom).offset(20)
            $0.leading.trailing.equalTo(titleInputBox)
        }
        
        memoInputBox.snp.makeConstraints {
            $0.top.equalTo(amountInputBox.snp.bottom).offset(20)
            $0.leading.trailing.equalTo(titleInputBox)
        }
        
        enterButton.snp.makeConstraints {
            $0.leading.trailing.equalTo(titleInputBox)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            $0.height.equalTo(48)
        }
    }
    
    func bindViewModel() {
        let input = AddBillViewModel.Input(
            titleText: titleInputBox.inputTextField.rx.text.orEmpty.asObservable(),
            dateText: dateInputBox.datePickerView.rx.date.asObservable(),
            amountText: amountInputBox.inputTextField.rx.text.orEmpty.asObservable(),
            memoText: memoInputBox.inputTextField.rx.text.orEmpty.asObservable(),
            enterButton: enterButton.rx.tap.asObservable()
        )
                
        let output = viewModel.transform(input: input)
        
        output.isEnterEnabled
            .drive(
                onNext: { [weak self] in
                    self?.enterButton.isEnabled = $0
                }
            )
            .disposed(by: disposeBag)
        
        output.addBill
            .subscribe(
                onNext: { [weak self] in
                    self?.dismiss(animated: true) { [weak self] in
                        self?.delegate?.updateBillList()
                    }
                }
            )
            .disposed(by: disposeBag)
    }
    
    
}
