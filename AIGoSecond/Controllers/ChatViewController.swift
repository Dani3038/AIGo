//
//  ChatViewController.swift
//  AIGoSecond
//
//  Created by 정다운 on 5/20/25.
//

import UIKit

class ChatViewController: UIViewController {

    var userNickname: String? // NicknameSettingViewController에서 전달받을 닉네임
    private let nunProfileImageView = UIImageView() // 수녀님 프로필 이미지 뷰
    private let nunNameLabel = UILabel() // 수녀님 이름 라벨
    private let chatTableView = UITableView()
    private let messageInputTextField = UITextField()
    private let sendButton = UIButton(type: .system)
    
    private let inputContainerView = UIView()
    private var inputContainerViewBottomConstraint: NSLayoutConstraint!

    // 메시지 데이터를 ChatMessage 구조체 배열로 변경
    private var messages: [ChatMessage] = []
    
    // chatService를 Optional이 아닌 명확한 타입으로 선언하고, viewDidLoad에서 닉네임이 설정된 후에 초기화합니다.
    private var chatService: OpenAIChatService!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupNavigationBar()
        setupUI()
        
        // 수녀님 프로필 설정
        // Assets에 Nun.png 이미지 추가 (예: page1.jpg에서 수녀님 부분만 잘라낸 이미지)
        // 제공된 파일 중 image_9be18a.jpg를 "Nun"으로 사용하시려면 이름을 변경하여 Assets에 추가하세요.
        nunProfileImageView.image = UIImage(named: "Nun")
        nunNameLabel.text = "수녀님"

        // MARK: - chatService 초기화 (viewDidLoad에서 닉네임 전달 후)
        // 보안을 위해 실제 앱에서는 이 키를 앱에 직접 하드코딩하지 않고,
        // 서버에서 가져오거나 다른 안전한 방법으로 관리하는 것이 좋음
        let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? ""
        
        // userNickname을 사용하여 chatService를 초기화합니다.
        chatService = OpenAIChatService(apiKey: apiKey, userNickname: userNickname)

        // 초기 메시지 (수녀님 인사말)
        messages.append(ChatMessage(text: "환영합니다. 고민을 이야기해 보세요.", type: .nun))
        chatTableView.reloadData() // 초기 메시지 로드 후 테이블 뷰 업데이트

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setupNavigationBar() {
        navigationItem.title = ""
        
        // "끝내기" 버튼
        let doneButton = UIBarButtonItem(title: "끝내기", style: .plain, target: self, action: #selector(endChat))
        doneButton.tintColor = .white
        navigationItem.rightBarButtonItem = doneButton
        
        navigationController?.navigationBar.tintColor = .white // 네비게이션 바 아이템 색상 (뒤로가기 버튼 등)
    }
    

    private func setupUI() {
        // 상단 수녀님 프로필 이미지
        nunProfileImageView.translatesAutoresizingMaskIntoConstraints = false
        nunProfileImageView.contentMode = .scaleAspectFit
        nunProfileImageView.layer.cornerRadius = 30 // 원형으로 보이도록
        nunProfileImageView.clipsToBounds = true
        view.addSubview(nunProfileImageView)
        
        // 수녀님 이름 라벨
        nunNameLabel.translatesAutoresizingMaskIntoConstraints = false
        nunNameLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        nunNameLabel.textColor = .white
        nunNameLabel.textAlignment = .center
        view.addSubview(nunNameLabel)

        // 채팅 테이블 뷰
        chatTableView.translatesAutoresizingMaskIntoConstraints = false
        chatTableView.backgroundColor = .clear
        chatTableView.separatorStyle = .none // 셀 구분선 없음
        chatTableView.dataSource = self
        chatTableView.delegate = self
        // 새로 만든 ChatCell 등록
        chatTableView.register(ChatCell.self, forCellReuseIdentifier: "ChatCell")
        chatTableView.estimatedRowHeight = 50 // 동적 높이 계산을 위한 추정치
        chatTableView.rowHeight = UITableView.automaticDimension // 셀 높이 자동 계산
        view.addSubview(chatTableView)

        // 입력 필드와 전송 버튼을 담을 컨테이너 뷰
        inputContainerView.translatesAutoresizingMaskIntoConstraints = false
        inputContainerView.backgroundColor = UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0) // 고민을 입력하세요 배경 더 어둡게
        view.addSubview(inputContainerView)
        
        // 메시지 입력 필드
        messageInputTextField.translatesAutoresizingMaskIntoConstraints = false
        messageInputTextField.placeholder = "고민을 입력하세요..."
        messageInputTextField.textColor = .white // 텍스트 색상을 흰색으로 변경하여 어두운 배경에 대비
        messageInputTextField.attributedPlaceholder = NSAttributedString(string: "고민을 입력하세요...", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]) // 플레이스홀더 색상
        messageInputTextField.backgroundColor = .clear
        messageInputTextField.borderStyle = .none
        inputContainerView.addSubview(messageInputTextField)

        // 전송 버튼
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.setTitle("전송", for: .normal)
        sendButton.setTitleColor(.systemPurple, for: .normal)
        sendButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside) // sendMessage -> sendButtonTapped로 변경
        inputContainerView.addSubview(sendButton)

        // Auto Layout 제약 조건 설정
        inputContainerViewBottomConstraint = inputContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        
        NSLayoutConstraint.activate([
            // 수녀님 프로필 이미지
            nunProfileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nunProfileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            nunProfileImageView.widthAnchor.constraint(equalToConstant: 60),
            nunProfileImageView.heightAnchor.constraint(equalToConstant: 60),
            
            // 수녀님 이름 라벨
            nunNameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nunNameLabel.topAnchor.constraint(equalTo: nunProfileImageView.bottomAnchor, constant: 5),

            // 입력 컨테이너 뷰
            inputContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            inputContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            inputContainerViewBottomConstraint,
            inputContainerView.heightAnchor.constraint(equalToConstant: 60),

            // 메시지 입력 필드
            messageInputTextField.leadingAnchor.constraint(equalTo: inputContainerView.leadingAnchor, constant: 15),
            messageInputTextField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -10),
            messageInputTextField.centerYAnchor.constraint(equalTo: inputContainerView.centerYAnchor),
            messageInputTextField.heightAnchor.constraint(equalToConstant: 40),

            // 전송 버튼
            sendButton.trailingAnchor.constraint(equalTo: inputContainerView.trailingAnchor, constant: -15),
            sendButton.centerYAnchor.constraint(equalTo: inputContainerView.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 50),

            // 채팅 테이블 뷰 (입력창과 겹치지 않도록 설정)
            chatTableView.topAnchor.constraint(equalTo: nunNameLabel.bottomAnchor, constant: 20), // 수녀님 프로필과 메시지 사이의 거리 조금 더 띄우기 (10 -> 20)
            chatTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            chatTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            chatTableView.bottomAnchor.constraint(equalTo: inputContainerView.topAnchor)
        ])
    }

    @objc private func endChat() {
        let endVC = EndViewController()
        navigationController?.pushViewController(endVC, animated: true)
    }
    
    @objc private func sendButtonTapped() { // sendMessage 대신 sendButtonTapped 사용
        guard let messageText = messageInputTextField.text, !messageText.isEmpty else { return }

        // 1. 사용자 메시지 추가 및 화면 업데이트
        let userMessage = ChatMessage(text: messageText, type: .user)
        messages.append(userMessage)
        chatTableView.reloadData()

        // 테이블 뷰를 가장 아래로 스크롤
        chatTableView.scrollToRow(at: IndexPath(row: messages.count - 1, section: 0), at: .bottom, animated: true)

        // 입력 필드 초기화
        messageInputTextField.text = ""

        // 2. OpenAI API 호출
        chatService.getChatGPTResponse(prompt: messageText) { [weak self] result in
            DispatchQueue.main.async { // UI 업데이트는 항상 메인 스레드에서!
                guard let self = self else { return }
                switch result {
                case .success(let nunResponse):
                    let nunMessage = ChatMessage(text: nunResponse, type: .nun)
                    self.messages.append(nunMessage)
                    self.chatTableView.reloadData()
                    // 새로운 메시지가 추가되면 다시 스크롤
                    self.chatTableView.scrollToRow(at: IndexPath(row: self.messages.count - 1, section: 0), at: .bottom, animated: true)
                case .failure(let error):
                    print("OpenAI API Error: \(error.localizedDescription)")
                    // 에러 처리: 사용자에게 메시지를 보여주는 등의 처리
                    let errorMessage = "수녀님과의 대화에 문제가 생겼어요. \(error.localizedDescription)"
                    let errorChat = ChatMessage(text: errorMessage, type: .nun) // 에러 메시지도 수녀님 메시지로 표시
                    self.messages.append(errorChat)
                    self.chatTableView.reloadData()
                    self.chatTableView.scrollToRow(at: IndexPath(row: self.messages.count - 1, section: 0), at: .bottom, animated: true)
                }
            }
        }
    }
    
    // MARK: - Keyboard Handling
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }

        let keyboardHeight = keyboardFrame.height
        inputContainerViewBottomConstraint.constant = -keyboardHeight + view.safeAreaInsets.bottom
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        inputContainerViewBottomConstraint.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate (채팅 메시지 표시)
extension ChatViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // ChatCell로 다운캐스팅
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell", for: indexPath) as? ChatCell else {
            return UITableViewCell()
        }
        
        let message = messages[indexPath.row]
        cell.configure(with: message) // 커스텀 셀 configure 메서드 호출
        
        return cell
    }
}
