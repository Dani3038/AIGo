//
//  MessageType.swift
//  AIGoSecond
//
//  Created by 정다운 on 5/20/25.
//

import Foundation

enum MessageType {
    case user
    case nun
}

struct ChatMessage {
    let text: String
    let type: MessageType
}
