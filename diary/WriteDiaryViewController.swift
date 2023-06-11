//
//  WriteDiaryViewController.swift
//  diary
//
//  Created by logispot on 2023/06/10.
//

import UIKit

enum DiaryEditorMode {
    case new
    case edit(IndexPath, Diary)
}

protocol WriteDiaryViewDelegate: AnyObject {
    
    func didSelectRegister(diary: Diary)
}

class WriteDiaryViewController: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var dateTextField: UITextField!

    @IBOutlet weak var confirmButton: UIBarButtonItem!
    
    private let datePicker = UIDatePicker()
    private var diaryDate: Date?
    weak var delegate: WriteDiaryViewDelegate?
    var diaryEditorMode: DiaryEditorMode = .new
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.configureContentsTextView()
        self.configureDatePicker()
        self.configureInputField()
        self.configureEditMode()
        self.confirmButton.isEnabled = false
    }
    
    private func configureEditMode() {
        switch self.diaryEditorMode {
        case let .edit(_, diary):
            self.titleTextField.text = diary.title
            self.contentsTextView.text = diary.contents
            self.dateTextField.text = self.dateToString(date: diary.date)
            self.diaryDate = diary.date
            self.confirmButton.title = "수정"
            
        default:
            break
        }
    }
    
    private func dateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월 dd일(EEEEE)"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
    
    private func configureContentsTextView() {
        let borderColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0)
        
        self.contentsTextView.layer.borderColor = borderColor.cgColor
        self.contentsTextView.layer.borderWidth = 0.5
        self.contentsTextView.layer.cornerRadius = 5.0
    }
    
    private func configureDatePicker() {
        self.datePicker.datePickerMode = .date
        self.datePicker.preferredDatePickerStyle = .wheels
        self.datePicker.addTarget(self, action: #selector(datePickerValueDidChange(_:)), for:
                .valueChanged)
        self.datePicker.locale = Locale(identifier: "ko_KR")
        //self.datePicker.locale = Locale(identifier: "en_US")
        self.dateTextField.inputView = self.datePicker
        
    }
    
    private func configureInputField() {
        self.contentsTextView.delegate = self
        self.titleTextField.addTarget(self, action: #selector(titleTextFieldDidChange(_:)), for:
                .editingChanged
        )
        self.dateTextField.addTarget(self, action: #selector(dateTextFieldDidChange(_:)), for:
                .editingChanged)
    }
    
    @objc private func datePickerValueDidChange(_ datePicker: UIDatePicker) {
        let formmater = DateFormatter()
        formmater.dateFormat = "yyyy년 MM월 dd일(EEEEE)"
        formmater.locale = Locale(identifier: "ko_KR")
        //formmater.locale = Locale(identifier: "en_US")
        //formmater.dateFormat = "yyyy년 MM월 dd일 (EEEEE)"
        self.diaryDate = datePicker.date
        self.dateTextField.text = formmater.string(from: datePicker.date)
        self.dateTextField.sendActions(for: .editingChanged)
    }
    
    //여기서는 TextField 를 감지하는것을 @objc 으로 만듬
    @objc private func titleTextFieldDidChange(_ textField: UITextField) {
        self.validateInputField()
    }
    
    //여기서는 TextField 를 감지하는것을 @objc 으로 만듬
    @objc private func dateTextFieldDidChange(_ textField: UITextField) {
        self.validateInputField()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    private func validateInputField() {
        self.confirmButton.isEnabled =
        !(self.titleTextField.text?.isEmpty ?? true) &&
        !(self.dateTextField.text?.isEmpty ?? true) &&
        !self.contentsTextView.text.isEmpty
    }
    
    //등록 버튼을 클릭할시 활성화 되는 func
    @IBAction func tapConfirmButton(_ sender: UIBarButtonItem) {
        guard let title = self.titleTextField.text else {
            return
        }
        guard let contents = self.contentsTextView.text else {
            return
        }
        guard let date = self.diaryDate else { return }
        let diary = Diary(title: title, contents: contents, date: date, isStar: false)
        
        switch self.diaryEditorMode {
        case .new:
            self.delegate?.didSelectRegister(diary: diary)
        case let .edit(indexPath, _):
            NotificationCenter.default.post(
                name: NSNotification.Name("editDiary"),
                object: diary,
                userInfo: [
                    "indexPath.row": indexPath.row
                ]
                )
        }
        //diary data를 인터페이스를 통해서 넘김
        //self.delegate?.didSelectRegister(diary: diary)
        //네비게이션으로 stack 으로 쌓인 지금 뷰를 pop 해서 이전 뷰로 이동.
        self.navigationController?.popViewController(animated: true)
        
    }
}

extension WriteDiaryViewController: UITextViewDelegate {

    //여기서 textView 감지하는 것을 인터페이스로 만듬
    func textViewDidChange(_ textView: UITextView) {
        self.validateInputField()
    }
}
