//
//  ViewController.swift
//  BMICalculator
//
//  Created by 이재희 on 1/3/24.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var detailLabel: UILabel!
    @IBOutlet var imageView: UIImageView!

    @IBOutlet var labelList: [UILabel]!
    @IBOutlet var textFieldList: [UITextField]!
    
    @IBOutlet var showWeightButton: UIButton!
    @IBOutlet var randomCalculateButton: UIButton!
    @IBOutlet var resultButton: UIButton!
    
    @IBOutlet var showMyBMISwitch: UISwitch!
    
    let limitRanges = [(100...300), (30...300)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    // MARK: - Setup
    
    func setupUI() {
        titleLabel.text = "BMI Calculator"
        titleLabel.font = .boldSystemFont(ofSize: 24)
        
        setDetailLabelText()
        detailLabel.font = .systemFont(ofSize: 15)
        detailLabel.numberOfLines = 2
        
        labelList[0].text = "키가 어떻게 되시나요?"
        labelList[1].text = "몸무게는 어떻게 되시나요?"
        labelList.forEach { $0.font = .systemFont(ofSize: 13) }
        
        settingTextFields()
        textFieldList[1].isSecureTextEntry = true
        for tf in textFieldList {
            tf.layer.borderWidth = 1
            tf.layer.cornerRadius = 12
            tf.clipsToBounds = true
            tf.keyboardType = .numberPad
        }

        showWeightButton.tintColor = .systemGray
        showWeightButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        showWeightButton.setImage(UIImage(systemName: "eye"), for: .selected)
        
        randomCalculateButton.setTitle("랜덤으로 BMI 계산하기", for: .normal)
        randomCalculateButton.setTitleColor(.systemRed, for: .normal)
        randomCalculateButton.titleLabel?.font = .systemFont(ofSize: 12)
        
        resultButton.backgroundColor = .systemPurple
        resultButton.setTitle("결과 확인", for: .normal)
        resultButton.setTitleColor(.white, for: .normal)
        resultButton.titleLabel?.font = .boldSystemFont(ofSize: 18)
        resultButton.layer.cornerRadius = 8
    }
    
    // MARK: - Actions
    
    @IBAction func keyboardDismiss(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    // 버튼 탭하면 몸무게 보였다가 안보였다가..
    @IBAction func showWeightButtonTapped(_ sender: UIButton) {
        textFieldList[1].isSecureTextEntry.toggle()
        showWeightButton.isSelected.toggle()
    }
    
    @IBAction func randomCalculateButtonTapped(_ sender: UIButton) {
        for (i, tf) in textFieldList.enumerated() {
            tf.text = "\(Int.random(in: limitRanges[i]))"
            textFieldEditing(tf)
        }
    }
    
    @IBAction func resultButtonTapped(_ sender: UIButton) {
        guard let text = textFieldList[0].text, let height = Double(text) else {
            showAlert(title: "오류 발생", message: "키 옵셔널 바인딩 실패")
            return
        }
        
        guard let text = textFieldList[1].text, let weight = Double(text) else {
            showAlert(title: "오류 발생", message: "몸무게 옵셔널 바인딩 실패")
            return
        }
        
        let bmi = getBmi(height: height, weight: weight)
        
        if showMyBMISwitch.isOn {
            saveInfo()
        }
        
        showAlert(title: "BMI : " + String(format: "%.1f", bmi), message: "\n\(getBmiState(bmi: bmi)) 입니다!")
    }
    
    // 실시간으로 유효성 검사해서 borderColor 변경, 숫자만 입력되게 구현
    @IBAction func textFieldEditing(_ sender: UITextField) {
        if var text = sender.text, !text.isEmpty {
            text.removeAll { !$0.isNumber }
            
            if let num = Int(text), limitRanges[sender.tag] ~= num {
                sender.layer.borderColor = UIColor.systemGreen.cgColor
            } else {
                sender.layer.borderColor = UIColor.systemRed.cgColor
            }
        } else {
            sender.layer.borderColor = UIColor.black.cgColor
        }
        validateResultButton()
    }
    
    // 나의 BMI 스위치가 켜져있는 경우에만 닉네임을 보여주고 키, 몸무게를 저장
    @IBAction func switchValueChanged(_ sender: UISwitch) {
        if sender.isOn {
            settingTextFields()
        } else {
            emptyTextFields()
        }
        setDetailLabelText()
    }
    
    @IBAction func editNameButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "닉네임 변경", message: "변경할 닉네임을 입력하세요.", preferredStyle: .alert)
        
        let button1 = UIAlertAction(title: "삭제", style: .destructive) { _ in
            UserDefaults.standard.removeObject(forKey: "name")
            self.setDetailLabelText()
        }
        let button2 = UIAlertAction(title: "확인", style: .default) { _ in
            if let textField = alert.textFields?[0], let newName = textField.text, !newName.isEmpty {
                UserDefaults.standard.set(newName, forKey: "name")
                self.setDetailLabelText()
            } else {
                UserDefaults.standard.removeObject(forKey: "name")
                self.setDetailLabelText()
            }
        }
        
        alert.addAction(button1)
        alert.addAction(button2)
        alert.addTextField()
        alert.textFields?[0].text = UserDefaults.standard.string(forKey: "name")
        
        view.endEditing(true)
        present(alert, animated: true)
    }
    
    // MARK: - Functions
    
    func getBmi(height: Double, weight: Double) -> Double {
        return weight / pow(height/100, 2)
    }
    
    func getBmiState(bmi: Double) -> String {
        switch bmi {
        case ..<18.5: return "저체중"
        case 18.5..<23: return "정상"
        case 23..<25: return "과체중"
        case 25...: return "비만"
        default: return "알 수 없음"
        }
    }
    
    // 텍스트필드들에 입력된 값 범위 검증해서 결과 확인 버튼 활성화 여부 판단
    func validateResultButton() {
        let isValid = textFieldList.allSatisfy { $0.layer.borderColor == UIColor.systemGreen.cgColor }
        resultButton.isEnabled = isValid
        resultButton.alpha = isValid ? 1 : 0.3
    }
    
    // alert창에서 리셋 선택하면 텍스트필드들 리셋
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let button1 = UIAlertAction(title: "삭제", style: .destructive) { _ in
            self.resetTextFields()
        }
        let button2 = UIAlertAction(title: "확인", style: .default)
        
        alert.addAction(button1)
        alert.addAction(button2)
        
        view.endEditing(true)
        present(alert, animated: true)
    }
    
    func settingTextFields() {
        textFieldList[0].text = UserDefaults.standard.string(forKey: "height")
        textFieldList[1].text = UserDefaults.standard.string(forKey: "weight")
        textFieldEditing(textFieldList[0])
        textFieldEditing(textFieldList[1])
    }
    
    func emptyTextFields() {
        for tf in textFieldList {
            tf.text = nil
            textFieldEditing(tf)
        }
    }
    
    func resetTextFields() {
        emptyTextFields()
        if showMyBMISwitch.isOn {
            UserDefaults.standard.removeObject(forKey: "height")
            UserDefaults.standard.removeObject(forKey: "weight")
        }
    }
    
    func saveInfo() {
        UserDefaults.standard.set(textFieldList[0].text, forKey: "height")
        UserDefaults.standard.set(textFieldList[1].text, forKey: "weight")
    }
    
    func setDetailLabelText() {
        if let name = UserDefaults.standard.string(forKey: "name"), showMyBMISwitch.isOn {
            detailLabel.text = "\(name)님의 BMI 지수를\n알려드릴게요."
        } else {
            detailLabel.text = "당신의 BMI 지수를\n알려드릴게요."
        }
    }
}

