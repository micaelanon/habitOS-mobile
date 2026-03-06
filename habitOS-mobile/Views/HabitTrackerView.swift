import SwiftUI

struct HabitTrackerView: View {
    let habits: [Habit]
    let onToggle: (Habit) -> Void

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                Text("Mis Hábitos")
                    .font(.hbSerifBold(30))
                    .foregroundStyle(Color.hbInk)
                    .staggered(index: 0)

                ForEach(Array(habits.enumerated()), id: \.element.id) { index, habit in
                    Button { onToggle(habit) } label: {
                        HBCard(highlighted: habit.isCompletedToday) {
                            HStack(spacing: 14) {
                                ZStack {
                                    Circle()
                                        .stroke(habit.isCompletedToday ? Color.hbSage : Color.hbLine, lineWidth: 1.5)
                                        .frame(width: 24, height: 24)
                                    if habit.isCompletedToday {
                                        Circle().fill(Color.hbSage).frame(width: 24, height: 24)
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 11, weight: .bold))
                                            .foregroundStyle(Color.hbVanilla)
                                    }
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(habit.name)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundStyle(habit.isCompletedToday ? Color.hbMuted2 : Color.hbInk)
                                        .strikethrough(habit.isCompletedToday, color: Color.hbMuted2)

                                    HStack(spacing: 6) {
                                        Image(systemName: "circle.dotted")
                                            .font(.system(size: 10))
                                            .foregroundStyle(Color.hbSage)
                                        Text("\(habit.streak) días")
                                            .font(.system(size: 12))
                                            .foregroundStyle(Color.hbMuted)
                                    }
                                }

                                Spacer()

                                if habit.isCompletedToday {
                                    HBBadge(text: "✓", style: .accent)
                                }
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .staggered(index: index + 1)
                }

                Spacer(minLength: 32)
            }
            .padding(.horizontal, HBTokens.padScreen)
            .padding(.top, 8)
        }
        .background(Color.hbVanilla)
    }
}
