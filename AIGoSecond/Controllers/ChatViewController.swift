// ChatViewController.swift
// 대화 횟수 제한: 최대 80회

import UIKit

class ChatViewController: UIViewController {

    var userNickname: String?
    private let nunProfileImageView = UIImageView()
    private let nunNameLabel = UILabel()
    private let chatTableView = UITableView()
    private let messageInputTextField = UITextField()
    private let sendButton = UIButton(type: .system)
    private let inputContainerView = UIView()
    private var inputContainerViewBottomConstraint: NSLayoutConstraint!

    private var messages: [ChatMessage] = []
    private var chatService: OpenAIChatService!
    var chatLimiter = ChatLimitManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupNavigationBar()
        setupUI()

        nunProfileImageView.image = UIImage(named: "Nun")
        nunNameLabel.text = "수녀님"

        let apiKey = Bundle.main.infoDictionary?["OPENAI_API_KEY"] as? String ?? ""
        chatService = OpenAIChatService(apiKey: apiKey, userNickname: userNickname)

        messages.append(ChatMessage(text: "환영합니다. 고민을 이야기해 보세요.", type: .nun))
        chatTableView.reloadData()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setupNavigationBar() {
        navigationItem.title = ""
        let doneButton = UIBarButtonItem(title: "끝내기", style: .plain, target: self, action: #selector(endChat))
        doneButton.tintColor = .white
        navigationItem.rightBarButtonItem = doneButton
        navigationController?.navigationBar.tintColor = .white
    }

    private func setupUI() {
        nunProfileImageView.translatesAutoresizingMaskIntoConstraints = false
        nunProfileImageView.contentMode = .scaleAspectFit
        nunProfileImageView.layer.cornerRadius = 30
        nunProfileImageView.clipsToBounds = true
        view.addSubview(nunProfileImageView)

        nunNameLabel.translatesAutoresizingMaskIntoConstraints = false
        nunNameLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        nunNameLabel.textColor = .white
        nunNameLabel.textAlignment = .center
        view.addSubview(nunNameLabel)

        chatTableView.translatesAutoresizingMaskIntoConstraints = false
        chatTableView.backgroundColor = .clear
        chatTableView.separatorStyle = .none
        chatTableView.dataSource = self
        chatTableView.delegate = self
        chatTableView.register(ChatCell.self, forCellReuseIdentifier: "ChatCell")
        chatTableView.estimatedRowHeight = 50
        chatTableView.rowHeight = UITableView.automaticDimension
        view.addSubview(chatTableView)

        inputContainerView.translatesAutoresizingMaskIntoConstraints = false
        inputContainerView.backgroundColor = UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0)
        view.addSubview(inputContainerView)

        messageInputTextField.translatesAutoresizingMaskIntoConstraints = false
        messageInputTextField.placeholder = "고민을 입력하세요..."
        messageInputTextField.textColor = .white
        messageInputTextField.attributedPlaceholder = NSAttributedString(string: "고민을 입력하세요...", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        messageInputTextField.backgroundColor = .clear
        messageInputTextField.borderStyle = .none
        inputContainerView.addSubview(messageInputTextField)

        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.setTitle("전송", for: .normal)
        sendButton.setTitleColor(.systemPurple, for: .normal)
        sendButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        inputContainerView.addSubview(sendButton)

        inputContainerViewBottomConstraint = inputContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)

        NSLayoutConstraint.activate([
            nunProfileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nunProfileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            nunProfileImageView.widthAnchor.constraint(equalToConstant: 60),
            nunProfileImageView.heightAnchor.constraint(equalToConstant: 60),

            nunNameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nunNameLabel.topAnchor.constraint(equalTo: nunProfileImageView.bottomAnchor, constant: 5),

            inputContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            inputContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            inputContainerViewBottomConstraint,
            inputContainerView.heightAnchor.constraint(equalToConstant: 60),

            messageInputTextField.leadingAnchor.constraint(equalTo: inputContainerView.leadingAnchor, constant: 15),
            messageInputTextField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -10),
            messageInputTextField.centerYAnchor.constraint(equalTo: inputContainerView.centerYAnchor),
            messageInputTextField.heightAnchor.constraint(equalToConstant: 40),

            sendButton.trailingAnchor.constraint(equalTo: inputContainerView.trailingAnchor, constant: -15),
            sendButton.centerYAnchor.constraint(equalTo: inputContainerView.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 50),

            chatTableView.topAnchor.constraint(equalTo: nunNameLabel.bottomAnchor, constant: 20),
            chatTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            chatTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            chatTableView.bottomAnchor.constraint(equalTo: inputContainerView.topAnchor)
        ])
    }

    @objc private func endChat() {
        let endVC = EndViewController()
        navigationController?.pushViewController(endVC, animated: true)
    }

    @objc private func sendButtonTapped() {
        guard let messageText = messageInputTextField.text, !messageText.isEmpty else { return }

        guard chatLimiter.canSendMessage() else {
            messages.append(ChatMessage(text: "수녀님과 나눌 수 있는 대화는 여기까지입니다.\n더 대화하시려면 비용을 지불해주세요!", type: .nun))
            chatTableView.reloadData()
            chatTableView.scrollToRow(at: IndexPath(row: messages.count - 1, section: 0), at: .bottom, animated: true)
            return
        }

        let userMessage = ChatMessage(text: messageText, type: .user)
        messages.append(userMessage)
        chatTableView.reloadData()
        chatTableView.scrollToRow(at: IndexPath(row: messages.count - 1, section: 0), at: .bottom, animated: true)

        messageInputTextField.text = ""
        chatLimiter.incrementChatCount()

        chatService.getChatGPTResponse(prompt: messageText) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let nunResponse):
                    let nunMessage = ChatMessage(text: nunResponse, type: .nun)
                    self.messages.append(nunMessage)
                    self.chatTableView.reloadData()
                    self.chatTableView.scrollToRow(at: IndexPath(row: self.messages.count - 1, section: 0), at: .bottom, animated: true)
                case .failure(let error):
                    let errorMessage = "수녀님과의 대화에 문제가 생겼어요. \(error.localizedDescription)"
                    self.messages.append(ChatMessage(text: errorMessage, type: .nun))
                    self.chatTableView.reloadData()
                    self.chatTableView.scrollToRow(at: IndexPath(row: self.messages.count - 1, section: 0), at: .bottom, animated: true)
                }
            }
        }
    }

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

extension ChatViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell", for: indexPath) as? ChatCell else {
            return UITableViewCell()
        }
        let message = messages[indexPath.row]
        cell.configure(with: message)
        return cell
    }
}
