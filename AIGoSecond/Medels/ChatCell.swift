import UIKit

class ChatCell: UITableViewCell {

    let messageLabel = UILabel()
    let bubbleBackgroundView = UIView()

    var leadingConstraint: NSLayoutConstraint!
    var trailingConstraint: NSLayoutConstraint!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        backgroundColor = .clear
        selectionStyle = .none

        bubbleBackgroundView.backgroundColor = .systemGray5
        bubbleBackgroundView.layer.cornerRadius = 10
        bubbleBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bubbleBackgroundView)

        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.numberOfLines = 0
        messageLabel.textColor = .white // Default, will be overridden
        messageLabel.font = UIFont.systemFont(ofSize: 17)
        bubbleBackgroundView.addSubview(messageLabel)

        // 내부의 메시지 라벨 제약 조건
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: bubbleBackgroundView.topAnchor, constant: 8),
            messageLabel.bottomAnchor.constraint(equalTo: bubbleBackgroundView.bottomAnchor, constant: -8),
            messageLabel.leadingAnchor.constraint(equalTo: bubbleBackgroundView.leadingAnchor, constant: 12),
            messageLabel.trailingAnchor.constraint(equalTo: bubbleBackgroundView.trailingAnchor, constant: -12),
           
            messageLabel.widthAnchor.constraint(lessThanOrEqualToConstant: UIScreen.main.bounds.width * 0.7 - 24)
        ])

        // 버블 배경 뷰의 세로 위치 제약 조건
        NSLayoutConstraint.activate([
            bubbleBackgroundView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            bubbleBackgroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])

        // 버블 배경 뷰의 좌우 정렬 제약 조건 초기화 (처음에는 비활성화)
        leadingConstraint = bubbleBackgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15)
        trailingConstraint = bubbleBackgroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15)

        // 텍스트 라벨과 버블 뷰의 가로 방향 콘텐츠 압축 저항 및 허깅 우선순위 설정
        messageLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        messageLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        bubbleBackgroundView.setContentCompressionResistancePriority(.required, for: .horizontal)
        bubbleBackgroundView.setContentHuggingPriority(.defaultLow, for: .horizontal)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        // 셀 재사용 시 이전에 활성화된 제약 조건을 비활성화
        leadingConstraint.isActive = false
        trailingConstraint.isActive = false
    }

    func configure(with message: ChatMessage) {
        messageLabel.text = message.text

        // 이전 정렬 제약 조건들을 비활성화하여 충돌 방지
        leadingConstraint.isActive = false
        trailingConstraint.isActive = false

        if message.type == .user {
            bubbleBackgroundView.backgroundColor = .systemPurple
            messageLabel.textColor = .white
            
            // 사용자 메시지: 오른쪽에 정렬
            leadingConstraint.isActive = false
            trailingConstraint.isActive = true
            
            // 오른쪽으로 배치하기 위한 제약 조건 업데이트
            trailingConstraint.constant = -15 // contentView 우측에서 15pt
            leadingConstraint = bubbleBackgroundView.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 50) // 왼쪽 여백
            leadingConstraint.isActive = true

        } else { // .nun (수녀님 메시지)
            bubbleBackgroundView.backgroundColor = .systemGray3
            messageLabel.textColor = .black // 수녀님의 메세지 텍스트 색상 black
            
            // 수녀님 메시지: 왼쪽에 정렬
            leadingConstraint.constant = 15
            trailingConstraint.constant = -45
            leadingConstraint.isActive = true
            trailingConstraint.isActive = false
            messageLabel.textAlignment = .left
        }
    }
}
