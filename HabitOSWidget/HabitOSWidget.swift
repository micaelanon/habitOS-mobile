//
//  HabitOSWidget.swift
//  HabitOSWidget
//
//  Created by HabitOS
//

import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> HabitOSEntry {
        HabitOSEntry(date: Date(), configuration: ConfigurationAppIntent())
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> HabitOSEntry {
        HabitOSEntry(date: Date(), configuration: configuration)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<HabitOSEntry> {
        let entry = HabitOSEntry(date: Date(), configuration: configuration)
        // Refresh every hour or so
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        return Timeline(entries: [entry], policy: .after(nextUpdate))
    }
}

struct HabitOSEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
}

// MARK: - Colors
extension Color {
    static let hbVanilla = Color(red: 245/255, green: 242/255, blue: 235/255)
    static let hbInk = Color(red: 34/255, green: 38/255, blue: 36/255)
    static let hbSage = Color(red: 106/255, green: 142/255, blue: 111/255)
}

struct HabitOSWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            smallWidget
        case .systemMedium:
            mediumWidget
        default:
            smallWidget
        }
    }
    
    var smallWidget: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(Color.hbSage.opacity(0.2), lineWidth: 12)
                Circle()
                    .trim(from: 0, to: 0.75) // Demo data
                    .stroke(Color.hbSage, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 2) {
                    Text("75%")
                        .font(.system(size: 22, weight: .bold, design: .monospaced))
                        .foregroundColor(.hbInk)
                    Text("COMPLETADO")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.hbSage)
                        .tracking(1)
                }
            }
            .padding(8)
        }
        .containerBackground(Color.hbVanilla, for: .widget)
    }
    
    var mediumWidget: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(Color.hbSage.opacity(0.2), lineWidth: 14)
                Circle()
                    .trim(from: 0, to: 0.75)
                    .stroke(Color.hbSage, style: StrokeStyle(lineWidth: 14, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 2) {
                    Text("75%")
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                        .foregroundColor(.hbInk)
                }
            }
            .frame(width: 90, height: 90)
            .padding(.leading, 8)
            
            VStack(alignment: .leading, spacing: 10) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Siguiente Comida")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.hbSage)
                        .tracking(1)
                    Text("Almuerzo (14:30)")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.hbInk)
                }
                
                Divider().background(Color.hbSage.opacity(0.3))
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill").foregroundColor(.hbSage)
                        Text("Beber 2L de agua").font(.system(size: 12)).foregroundColor(.hbInk)
                    }
                    HStack(spacing: 6) {
                        Image(systemName: "circle").foregroundColor(.hbInk.opacity(0.3))
                        Text("Entrenamiento").font(.system(size: 12)).foregroundColor(.hbInk)
                    }
                }
            }
        }
        .containerBackground(Color.hbVanilla, for: .widget)
    }
}

struct HabitOSWidget: Widget {
    let kind: String = "HabitOSWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            HabitOSWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("HabitOS Progress")
        .description("Sigue tu adherencia y plan diario desde la pantalla de inicio.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemSmall) {
    HabitOSWidget()
} timeline: {
    HabitOSEntry(date: .now, configuration: ConfigurationAppIntent())
}
#Preview(as: .systemMedium) {
    HabitOSWidget()
} timeline: {
    HabitOSEntry(date: .now, configuration: ConfigurationAppIntent())
}
