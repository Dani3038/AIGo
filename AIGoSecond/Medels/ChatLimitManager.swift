//
//  ChatLimitManager.swift
//  AIGoSecond
//
//  Created by 정다운 on 5/22/25.
//

import Foundation

struct ChatLimitManager {
    private let maxTotalChats = 80
    private let chatCountKey = "total_chat_count"
    private let userDefaults = UserDefaults.standard

    func canSendMessage() -> Bool {
        let currentCount = userDefaults.integer(forKey: chatCountKey)
        return currentCount < maxTotalChats
    }

    func incrementChatCount() {
        var count = userDefaults.integer(forKey: chatCountKey)
        count += 1
        userDefaults.set(count, forKey: chatCountKey)
    }

    func remainingChats() -> Int {
        return maxTotalChats - userDefaults.integer(forKey: chatCountKey)
    }
}
