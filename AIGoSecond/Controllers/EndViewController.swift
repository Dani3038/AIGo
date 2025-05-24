import UIKit

class EndViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = ""
        setupUI()
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        // 뒤로가기 버튼 숨김
        navigationItem.setHidesBackButton(true, animated: false)
    }

    private func setupUI() {
        // 1. 배경 이미지
        let backgroundImageView = UIImageView()
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.image = UIImage(named: "bamboo_background")
        view.addSubview(backgroundImageView)

        // 2. 텍스트 라벨
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "오늘도 수고했어요\n당신 최고야"
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        titleLabel.textColor = .black
        view.addSubview(titleLabel)

        // 3. 수녀님 캐릭터 이미지 (thumbs up)
        let nunImageView = UIImageView()
        nunImageView.translatesAutoresizingMaskIntoConstraints = false
        nunImageView.contentMode = .scaleAspectFit
        nunImageView.image = UIImage(named: "Monk_good")
        view.addSubview(nunImageView)

        // 4. "조금 더 이야기 나누기" 버튼
        let talkMoreButton = UIButton(type: .system)
        talkMoreButton.translatesAutoresizingMaskIntoConstraints = false
        talkMoreButton.setTitle("조금 더 이야기 나누기", for: .normal)
        talkMoreButton.setTitleColor(.black, for: .normal)
        talkMoreButton.backgroundColor = .white
        talkMoreButton.layer.cornerRadius = 10
        talkMoreButton.layer.borderWidth = 1
        talkMoreButton.layer.borderColor = UIColor.lightGray.cgColor
        talkMoreButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        talkMoreButton.addTarget(self, action: #selector(talkMore), for: .touchUpInside)
        view.addSubview(talkMoreButton)

        // 5. "기록 삭제하기" 버튼
        let deleteRecordsButton = UIButton(type: .system)
        deleteRecordsButton.translatesAutoresizingMaskIntoConstraints = false
        deleteRecordsButton.setTitle("기록 삭제하기", for: .normal)
        deleteRecordsButton.setTitleColor(.white, for: .normal)
        deleteRecordsButton.backgroundColor = .darkGray
        deleteRecordsButton.layer.cornerRadius = 10
        deleteRecordsButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        deleteRecordsButton.addTarget(self, action: #selector(deleteRecords), for: .touchUpInside)
        view.addSubview(deleteRecordsButton)

        // Auto Layout 제약 조건 설정
        NSLayoutConstraint.activate([
            // 배경 이미지
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            // 텍스트 라벨
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 90),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            // 수녀님 이미지
            nunImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nunImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 90),
            nunImageView.widthAnchor.constraint(equalToConstant: 400),
            nunImageView.heightAnchor.constraint(equalToConstant: 400),

            // "조금 더 이야기 나누기" 버튼
            talkMoreButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            talkMoreButton.bottomAnchor.constraint(equalTo: deleteRecordsButton.topAnchor, constant: -20),
            talkMoreButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            talkMoreButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            talkMoreButton.heightAnchor.constraint(equalToConstant: 60),

            // "기록 삭제하기" 버튼
            deleteRecordsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            deleteRecordsButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            deleteRecordsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            deleteRecordsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            deleteRecordsButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    @objc private func talkMore() {
        if let navigationController = self.navigationController {
            for vc in navigationController.viewControllers {
                if let chatVC = vc as? ChatViewController {
                    navigationController.popToViewController(chatVC, animated: true)
                    return
                }
            }
            let newChatVC = ChatViewController()
            navigationController.pushViewController(newChatVC, animated: true)
        }
    }

    @objc private func deleteRecords() {
        // 채팅 기록 삭제 로직 (예: UserDefaults에서 닉네임 삭제)
        UserDefaults.standard.removeObject(forKey: "userNickname")
        print("채팅 기록 삭제 완료 및 닉네임 초기화")
        
        // 첫 페이지로 돌아가기 (Navigation Stack의 Root View Controller로)
        navigationController?.popToRootViewController(animated: true)
    }
}
