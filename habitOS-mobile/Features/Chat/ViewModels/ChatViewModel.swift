import SwiftUI
import Supabase

/// Chat ViewModel with Supabase Realtime subscription + demo fallback
@Observable
final class ChatViewModel {
    var messages: [CoachMessage] = []
    var messageText: String = ""
    var isLoading: Bool = false
    var isSending: Bool = false
    var errorMessage: String?
    var isRealtimeConnected: Bool = false
    var coachName: String = "Coach"

    private var profileId: UUID?
    private var realtimeChannel: RealtimeChannelV2?
    private let isDemoMode: Bool

    init(isDemoMode: Bool = false) {
        self.isDemoMode = isDemoMode
    }

    // MARK: – Load Messages

    func loadMessages(profileId: UUID, coachName: String) async {
        self.profileId = profileId
        self.coachName = coachName
        isLoading = true
        defer { isLoading = false }

        if isDemoMode {
            loadDemoMessages()
            return
        }

        // Fetch from Supabase
        do {
            let fetched: [CoachMessage] = try await SupabaseManager.shared.client
                .from("coach_messages")
                .select()
                .eq("profile_id", value: profileId.uuidString)
                .order("created_at", ascending: true)
                .limit(50)
                .execute()
                .value
            messages = fetched
        } catch {
            errorMessage = "Error al cargar mensajes"
            loadDemoMessages() // Fallback to demo
        }

        // Start realtime subscription
        await subscribeToRealtime()
    }

    // MARK: – Send Message

    func sendMessage() async {
        let text = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, let profileId = profileId else { return }

        isSending = true
        defer { isSending = false }

        let newMessage = CoachMessage(
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

        // Optimistic UI update
        messages.append(newMessage)
        messageText = ""

        if isDemoMode {
            // Demo: auto-reply after 1.5s
            try? await Task.sleep(for: .milliseconds(1500))
            let reply = CoachMessage(
                id: UUID(),
                profileId: profileId,
                role: .assistant,
                channel: "app",
                messageText: demoReply(for: text),
                mediaType: nil,
                mediaUrl: nil,
                metadata: nil,
                expiresAt: nil,
                createdAt: Date()
            )
            messages.append(reply)
            return
        }

        // Send to Supabase
        do {
            try await SupabaseManager.shared.client
                .from("coach_messages")
                .insert(newMessage)
                .execute()
        } catch {
            // Remove optimistic message on failure
            messages.removeAll { $0.id == newMessage.id }
            messageText = text
            errorMessage = "Error al enviar mensaje"
        }
    }

    // MARK: – Realtime Subscription

    private func subscribeToRealtime() async {
        guard !isDemoMode, let profileId = profileId else { return }

        let channel = SupabaseManager.shared.client
            .channel("coach-messages-\(profileId.uuidString.prefix(8))")

        let insertions = channel.postgresChange(
            InsertAction.self,
            schema: "public",
            table: "coach_messages",
            filter: "profile_id=eq.\(profileId.uuidString)"
        )

        await channel.subscribe()
        realtimeChannel = channel
        isRealtimeConnected = true

        for await insert in insertions {
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let message = try insert.decodeRecord(as: CoachMessage.self, decoder: decoder)
                // Avoid duplicates from optimistic updates
                if !messages.contains(where: { $0.id == message.id }) {
                    messages.append(message)
                }
            } catch {
                // Ignore decode errors silently
            }
        }
    }

    // MARK: – Demo Data

    private func loadDemoMessages() {
        let pid = profileId ?? UUID()
        let now = Date()
        messages = [
            CoachMessage(
                id: UUID(), profileId: pid, role: .assistant, channel: "app",
                messageText: "¡Hola Micael! 👋 ¿Cómo te fue ayer con la cena? Vi que seguiste el plan del almuerzo 💪",
                mediaType: nil, mediaUrl: nil, metadata: nil, expiresAt: nil,
                createdAt: now.addingTimeInterval(-3600)
            ),
            CoachMessage(
                id: UUID(), profileId: pid, role: .user, channel: "app",
                messageText: "¡Bien! Seguí el plan. Pero hoy como fuera con amigos…",
                mediaType: nil, mediaUrl: nil, metadata: nil, expiresAt: nil,
                createdAt: now.addingTimeInterval(-3500)
            ),
            CoachMessage(
                id: UUID(), profileId: pid, role: .assistant, channel: "app",
                messageText: "Perfecto 💪 Para comer fuera:\n• Elige proteína (carne/pescado a la plancha)\n• Evita fritos\n• Ensalada > pasta\n• Agua o infusión, nada de refrescos",
                mediaType: nil, mediaUrl: nil, metadata: nil, expiresAt: nil,
                createdAt: now.addingTimeInterval(-3400)
            ),
        ]
    }

    private func demoReply(for text: String) -> String {
        let lower = text.lowercased()
        if lower.contains("agua") || lower.contains("sed") {
            return "¡Bien hecho! Recuerda que necesitas al menos 2.5L al día. Puedes llevar una botella contigo 💧"
        } else if lower.contains("comer") || lower.contains("comida") || lower.contains("hambre") {
            return "¿Qué tal si revisas tu próxima comida del plan? Está pensada para mantenerte saciado 🍽"
        } else if lower.contains("peso") || lower.contains("kilos") {
            return "No te obsesiones con la báscula 📊 Lo importante es la tendencia a largo plazo. ¿Cómo te sientes?"
        } else if lower.contains("entren") || lower.contains("ejercicio") || lower.contains("gym") {
            return "¡Genial que estés activo! 🏋️ Recuerda que el descanso también es parte del entrenamiento."
        } else {
            return "¡Gracias por compartir! 😊 Sigo aquí para lo que necesites. ¿Hay algo específico en lo que pueda ayudarte?"
        }
    }

    deinit {
        Task { [realtimeChannel] in
            await realtimeChannel?.unsubscribe()
        }
    }
}
