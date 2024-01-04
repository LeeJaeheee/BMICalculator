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
    
    let limitRanges = [(100...300), (30...300)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = "BMI Calculator"
        titleLabel.font = .boldSystemFont(ofSize: 24)
        
        detailLabel.text = "당신의 BMI 지수를\n알려드릴게요."
        detailLabel.font = .systemFont(ofSize: 15)
        detailLabel.numberOfLines = 2
        
        labelList[0].text = "키가 어떻게 되시나요?"
        labelList[1].text = "몸무게는 어떻게 되시나요?"
        labelList.forEach { $0.font = .systemFont(ofSize: 13) }
        
        for tf in textFieldList {
            tf.layer.borderWidth = 1
            tf.layer.borderColor = UIColor.black.cgColor
            tf.layer.cornerRadius = 12
            tf.clipsToBounds = true
            tf.keyboardType = .numberPad
        }
        textFieldList[1].isSecureTextEntry = true
        
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
        resultButton.alpha = 0.3
        resultButton.isEnabled = false
    }
    
    @IBAction func keyboardDismiss(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
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
        showAlert(title: "BMI : " + String(format: "%.1f", bmi), message: "\n\(getBmiState(bmi: bmi)) 입니다!")
    }
    
    
    // FIXME: textFieldList[1]이 Editing Did End로 연결돼있음;
    @IBAction func textFieldEditing(_ sender: UITextField) {
        sender.text?.removeAll { !$0.isNumber }
        
        if sender.text == "" {
            sender.layer.borderColor = UIColor.black.cgColor
        } else if let num = Int(sender.text!), limitRanges[sender.tag] ~= num {
            sender.layer.borderColor = UIColor.systemGreen.cgColor
        } else {
            sender.layer.borderColor = UIColor.systemRed.cgColor
        }
        validateResultButton()
    }
    
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
    
    func validateResultButton() {
        let isValid = textFieldList.allSatisfy { $0.layer.borderColor == UIColor.systemGreen.cgColor }
        resultButton.isEnabled = isValid
        resultButton.alpha = isValid ? 1 : 0.3
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // TODO: 리셋 선택하면 텍스트필드들 리셋하기
        let button1 = UIAlertAction(title: "리셋", style: .destructive) { _ in
            self.resetTextFields()
        }
        let button2 = UIAlertAction(title: "확인", style: .default)
        
        alert.addAction(button1)
        alert.addAction(button2)
        
        present(alert, animated: true)
    }
    
    func resetTextFields() {
        for tf in textFieldList {
            tf.text = nil
            textFieldEditing(tf)
        }
    }
    
}

