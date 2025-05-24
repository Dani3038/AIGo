//
//  firstViewController.swift
//  AIGoSecond
//
//  Created by 정다운 on 5/20/25.
//
import UIKit

class FirstViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground // 또는 원하는 배경색으로 설정

        setupUI()
    }

    private func setupUI() {
        // 1. 배경 이미지 (대나무 이미지)
        let backgroundImageView = UIImageView()
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.image = UIImage(named: "bamboo_background")
        view.addSubview(backgroundImageView)

        // 2. 텍스트 라벨
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "스님과의 수다로\n오늘 하루, 마음의 짐을\n내려놓고 가세요"
        titleLabel.numberOfLines = 0 // 여러 줄 표시
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        titleLabel.textColor = .black // 이미지 배경과 대비되도록 색상 조절
        view.addSubview(titleLabel)

        // 3. 수녀님 캐릭터 이미지
        let MonkImageView = UIImageView()
        MonkImageView.translatesAutoresizingMaskIntoConstraints = false
        MonkImageView.contentMode = .scaleAspectFit // 이미지 비율 유지
        MonkImageView.image = UIImage(named: "Monk")
        view.addSubview(MonkImageView)

        // 4. "짐 덜어내러 가기" 버튼
        let startButton = UIButton(type: .system)
        startButton.translatesAutoresizingMaskIntoConstraints = false
        startButton.setTitle("짐 덜어내러 가기", for: .normal)
        startButton.setTitleColor(.white, for: .normal)
        startButton.backgroundColor = .darkGray // 어두운 회색 배경
        startButton.layer.cornerRadius = 12 // 모서리 둥글게
        startButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        startButton.addTarget(self, action: #selector(goToNicknameSetting), for: .touchUpInside)
        view.addSubview(startButton)

        // Auto Layout 제약 조건 설정
        NSLayoutConstraint.activate([
            // 배경 이미지
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            // 텍스트 라벨
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 120),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            // 수녀님 이미지
            MonkImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            MonkImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 155),
            MonkImageView.widthAnchor.constraint(equalToConstant: 280), // 이미지 크기 조절
            MonkImageView.heightAnchor.constraint(equalToConstant: 280),

            // 시작 버튼
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            startButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            startButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            startButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    @objc private func goToNicknameSetting() {
        let nicknameVC = NicknameSettingViewController()
        navigationController?.pushViewController(nicknameVC, animated: true)
    }
}
