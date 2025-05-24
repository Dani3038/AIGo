//
//  NicknameSettingViewController.swift
//  AIGoSecond
//
//  Created by 정다운 on 5/20/25.
//

import UIKit

class NicknameSettingViewController: UIViewController, UITextFieldDelegate {

    private let titleLabel = UILabel()
    private let nicknameTextField = UITextField()
    private let charCountLabel = UILabel() // 0/10 표시용
    private let completeButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "" // 네비게이션 바 타이틀 없음
        setupUI()
        setupNavigationBar()
    }

    private func setupNavigationBar() {
    }

    private func setupUI() {
        // 1. 텍스트 라벨
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "스님과의 대화에서 사용할\n닉네임을 설정해주세요"
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .left
        titleLabel.font = UIFont.systemFont(ofSize: 26, weight: .bold)
        view.addSubview(titleLabel)

        // 2. 닉네임 입력 필드
        nicknameTextField.translatesAutoresizingMaskIntoConstraints = false
        nicknameTextField.placeholder = "닉네임"
        nicknameTextField.borderStyle = .none // 기본 테두리 없음
        nicknameTextField.font = UIFont.systemFont(ofSize: 18)
        nicknameTextField.delegate = self
        nicknameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        view.addSubview(nicknameTextField)

        // 닉네임 입력 필드 아래 줄
        let underlineView = UIView()
        underlineView.translatesAutoresizingMaskIntoConstraints = false
        underlineView.backgroundColor = .lightGray
        view.addSubview(underlineView)

        // 3. 글자 수 제한 라벨 (0/10)
        charCountLabel.translatesAutoresizingMaskIntoConstraints = false
        charCountLabel.text = "0/10"
        charCountLabel.textColor = .gray
        charCountLabel.font = UIFont.systemFont(ofSize: 14)
        charCountLabel.textAlignment = .right
        view.addSubview(charCountLabel)

        // 4. "설정 완료" 버튼
        completeButton.translatesAutoresizingMaskIntoConstraints = false
        completeButton.setTitle("설정 완료", for: .normal)
        completeButton.setTitleColor(.white, for: .normal)
        completeButton.backgroundColor = .lightGray // 초기 비활성화 상태 색상
        completeButton.layer.cornerRadius = 10
        completeButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        completeButton.isEnabled = false // 초기 비활성화
        completeButton.addTarget(self, action: #selector(completeSetting), for: .touchUpInside)
        view.addSubview(completeButton)

        // Auto Layout 제약 조건 설정
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            nicknameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 50),
            nicknameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nicknameTextField.trailingAnchor.constraint(equalTo: charCountLabel.leadingAnchor, constant: -10),

            underlineView.topAnchor.constraint(equalTo: nicknameTextField.bottomAnchor, constant: 5),
            underlineView.leadingAnchor.constraint(equalTo: nicknameTextField.leadingAnchor),
            underlineView.trailingAnchor.constraint(equalTo: charCountLabel.trailingAnchor),
            underlineView.heightAnchor.constraint(equalToConstant: 1),

            charCountLabel.centerYAnchor.constraint(equalTo: nicknameTextField.centerYAnchor),
            charCountLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            charCountLabel.widthAnchor.constraint(equalToConstant: 50), // 0/10 텍스트 공간 확보

            completeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            completeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            completeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            completeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            completeButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    // MARK: - UITextFieldDelegate

    @objc private func textFieldDidChange(_ textField: UITextField) {
        if let text = textField.text {
            // 최대 10글자 제한
            if text.count > 10 {
                textField.text = String(text.prefix(10))
            }
            charCountLabel.text = "\(textField.text?.count ?? 0)/10"
            updateCompleteButtonState(with: textField.text)
        }
    }

    private func updateCompleteButtonState(with text: String?) {
        if let text = text, !text.isEmpty {
            completeButton.isEnabled = true
            completeButton.backgroundColor = .darkGray // 활성화 색상
        } else {
            completeButton.isEnabled = false
            completeButton.backgroundColor = .lightGray // 비활성화 색상
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // 키보드 내리기
        return true
    }

    @objc private func completeSetting() {
        guard let nickname = nicknameTextField.text, !nickname.isEmpty else {
            // 닉네임이 비어있을 경우 처리
            let alert = UIAlertController(title: "알림", message: "닉네임을 입력해주세요.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        // 닉네임을 다음 화면으로 전달
        let chatVC = ChatViewController()
        chatVC.userNickname = nickname
        navigationController?.pushViewController(chatVC, animated: true)
    }
}
