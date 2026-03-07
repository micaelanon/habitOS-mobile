import Foundation
import Supabase

/// Chat repository — reads coach messages from Supabase
final class ChatRepository: ChatRepositoryProtocol {
    private let client = SupabaseManager.shared.client

    func fetchMessages(profileId: UUID, limit: Int) async throws -> [CoachMessage] {
        let messages: [CoachMessage] = try await client.database
            .from("coach_messages")
            .select()
            .eq("profile_id", value: profileId.uuidString)
            .order("created_at", ascending: true)
            .limit(limit)
            .execute()
            .value
        return messages
    }

    func sendMessage(profileId: UUID, text: String) async throws -> CoachMessage {
        let message = CoachMessage(
            id: UUID(),
            profileId: profileId,
            role: .user,
            channel: "app",
            messageText: text,
            mediaType: nil,
            mediaUrl: nil,
            metadata: nil,
            expiresAt: nil,
            createdAt: Date()
        )
        try await client.database
            .from("coach_messages")
            .insert(message)
            .execute()
        return message
    }

    func subscribeToMessages(profileId: UUID, onNew: @escaping (CoachMessage) -> Void) async {
        // Realtime subscription is managed by ChatViewModel directly
    }
}
