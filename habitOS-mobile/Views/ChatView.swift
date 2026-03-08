import SwiftUI

struct ChatView: View {
    let messages: [CoachMessage]
    let coachName: String

    @State private var newMessage: String = ""
    @State private var showQuickReplies = true

    private let quickReplies = [
        "Seguí el plan ✓",
        "No pude hoy",
        "Tengo hambre",
        "Una duda…",
    ]

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 14) {
                        Text("HOY")
                            .font(.hbKicker(9))
                            .tracking(3)
                            .foregroundStyle(Color.hbMuted2)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 5)
                            .background(Color.hbLine.opacity(0.5), in: RoundedRectangle(cornerRadius: 6))
                            .frame(maxWidth: .infinity)
                            .padding(.top, 12)

                        ForEach(Array(messages.enumerated()), id: \.element.id) { index, message in
                            messageBubble(message).id(message.id).staggered(index: index)
                        }
                    }
                    .padding(.horizontal, HBTokens.padScreen)
                    .padding(.bottom, 12)
                }
                .onAppear {
                    if let lastId = messages.last?.id { proxy.scrollTo(lastId, anchor: .bottom) }
                }
            }

            // Quick replies
            if showQuickReplies {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(quickReplies, id: \.self) { reply in
                            Button {
                                newMessage = reply
                                withAnimation { showQuickReplies = false }
                            } label: {
                                Text(reply)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(Color.hbSage)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(Color.hbSageBg, in: RoundedRectangle(cornerRadius: HBTokens.radiusSmall))
                                    .overlay(RoundedRectangle(cornerRadius: HBTokens.radiusSmall)
                                        .stroke(Color.hbSage.opacity(0.15), lineWidth: 1))
                            }
                        }
                    }
                    .padding(.horizontal, HBTokens.padScreen)
                    .padding(.vertical, 10)
                }
            }

            // Input bar
            HStack(spacing: 10) {
                TextField("Escribe un mensaje…", text: $newMessage)
                    .font(.system(size: 14))
                    .foregroundStyle(Color.hbInk)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color.hbVanilla, in: RoundedRectangle(cornerRadius: HBTokens.radiusMedium))
                    .overlay(RoundedRectangle(cornerRadius: HBTokens.radiusMedium)
                        .stroke(Color.hbLine, lineWidth: 1))

                Button {} label: {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(newMessage.isEmpty ? Color.hbMuted2 : Color.hbVanilla)
                        .frame(width: 36, height: 36)
                        .background(
                            newMessage.isEmpty ? Color.hbLine.opacity(0.5) : Color.hbSage,
                            in: Circle()
                        )
                }
                .disabled(newMessage.isEmpty)
                .animation(.easeInOut(duration: 0.15), value: newMessage.isEmpty)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.hbPaper)
        }
        .background(Color.hbVanilla)
    }

    private func messageBubble(_ message: CoachMessage) -> some View {
        HStack(alignment: .bottom, spacing: 8) {
            if message.role == .user { Spacer(minLength: 48) }

            if message.role == .assistant {
                Circle()
                    .fill(Color.hbSageBg)
                    .frame(width: 28, height: 28)
                    .overlay(
                        Image(systemName: "person")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Color.hbSage)
                    )
            }

            VStack(alignment: message.role == .assistant ? .leading : .trailing, spacing: 4) {
                Text(message.text)
                    .font(.system(size: 14))
                    .lineSpacing(3)
                    .foregroundStyle(message.role == .user ? Color.hbVanilla : Color.hbInk)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        message.role == .user
                            ? AnyShapeStyle(Color.hbSage)
                            : AnyShapeStyle(Color.hbPaper),
                        in: RoundedRectangle(cornerRadius: HBTokens.radiusLarge)
                    )
                    .overlay(
                        message.role == .assistant
                        ? RoundedRectangle(cornerRadius: HBTokens.radiusLarge).stroke(Color.hbLine, lineWidth: 1) : nil
                    )
                    .shadow(color: .black.opacity(0.04), radius: 8, y: 4)

                Text(timeString(message.timestamp))
                    .font(.system(size: 10))
                    .foregroundStyle(Color.hbMuted2)
                    .padding(.horizontal, 4)
            }

            if message.role == .assistant { Spacer(minLength: 48) }
        }
    }

    private func timeString(_ date: Date) -> String {
        let fmt = DateFormatter(); fmt.dateFormat = "HH:mm"; return fmt.string(from: date)
    }
}
