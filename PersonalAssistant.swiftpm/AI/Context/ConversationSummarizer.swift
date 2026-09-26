// AI/Context/ConversationSummarizer.swift
// Summarizes long conversation histories to fit within token limits.
// Per V3 §AI/Context/ConversationSummarizer.swift blueprint.

import Foundation

struct ConversationSummarizer: Sendable {
    static func compactMessages(messages: [MessageRecord], maxCount: Int = 10) -> [MessageRecord] {
        if messages.count <= maxCount {
            return messages
        }
        return Array(messages.suffix(maxCount))
    }
}
