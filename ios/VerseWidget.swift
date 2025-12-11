import WidgetKit
import SwiftUI

// MARK: - Widget Timeline Entry
struct VerseEntry: TimelineEntry {
    let date: Date
    let verseText: String
    let verseReference: String
    let verseTranslation: String
}

// MARK: - Timeline Provider
struct VerseProvider: TimelineProvider {
    // App Groups identifier (must match Flutter configuration)
    let appGroupId = "group.com.edcfaith.shared"

    // Placeholder (shown in widget gallery)
    func placeholder(in context: Context) -> VerseEntry {
        VerseEntry(
            date: Date(),
            verseText: "For God so loved the world that he gave his one and only Son, that whoever believes in him shall not perish but have eternal life.",
            verseReference: "John 3:16",
            verseTranslation: "KJV"
        )
    }

    // Snapshot (shown when adding widget to home screen)
    func getSnapshot(in context: Context, completion: @escaping (VerseEntry) -> ()) {
        let entry = loadVerseFromUserDefaults() ?? placeholder(in: context)
        completion(entry)
    }

    // Timeline (determines when widget updates)
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        // Load verse from shared UserDefaults
        let entry = loadVerseFromUserDefaults() ?? placeholder(in: context)

        // Calculate next midnight for update
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date())!
        let nextMidnight = calendar.startOfDay(for: tomorrow)

        // Create timeline with single entry, updating at next midnight
        let timeline = Timeline(entries: [entry], policy: .after(nextMidnight))
        completion(timeline)
    }

    // Helper: Load verse from App Groups shared UserDefaults
    private func loadVerseFromUserDefaults() -> VerseEntry? {
        guard let userDefaults = UserDefaults(suiteName: appGroupId) else {
            print("[VerseWidget] ❌ Failed to access App Groups UserDefaults")
            return nil
        }

        guard let verseText = userDefaults.string(forKey: "verseText"),
              let verseReference = userDefaults.string(forKey: "verseReference") else {
            print("[VerseWidget] ⚠️ Verse data not found in UserDefaults")
            return nil
        }

        let verseTranslation = userDefaults.string(forKey: "verseTranslation") ?? "KJV"

        print("[VerseWidget] ✅ Loaded verse: \(verseReference)")

        return VerseEntry(
            date: Date(),
            verseText: verseText,
            verseReference: verseReference,
            verseTranslation: verseTranslation
        )
    }
}

// MARK: - Widget View
struct VerseWidgetView: View {
    var entry: VerseProvider.Entry
    @Environment(\.widgetFamily) var widgetFamily

    var body: some View {
        ZStack {
            // Purple gradient background matching app theme
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.4, green: 0.2, blue: 0.6), // Deep purple
                    Color(red: 0.3, green: 0.1, blue: 0.5)  // Darker purple
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Widget content
            VStack(alignment: .leading, spacing: 0) {
                // Header with app logo (glassmorphic container matching FAB menu style)
                HStack {
                    // App logo in glassmorphic container (matching FAB menu design)
                    ZStack {
                        // Glass background
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white.opacity(0.05))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(red: 0.83, green: 0.69, blue: 0.22), lineWidth: 1) // Gold border
                            )

                        // Logo (language-aware: Spanish or English)
                        Image("AppLogo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(4)
                    }
                    .frame(width: 40, height: 40)

                    Spacer()

                    // Translation badge (small, subtle)
                    Text(entry.verseTranslation)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(Color(red: 0.83, green: 0.69, blue: 0.22)) // Gold
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white.opacity(0.1))
                        )
                }
                .padding(.bottom, 12)

                // Verse text (main content)
                Text(entry.verseText)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.white)
                    .lineLimit(5)
                    .minimumScaleFactor(0.8)
                    .multilineTextAlignment(.leading)

                Spacer()

                // Reference (bottom-right, gold color)
                HStack {
                    Spacer()
                    Text(entry.verseReference)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(red: 0.83, green: 0.69, blue: 0.22)) // Gold
                }
                .padding(.top, 8)
            }
            .padding(16)
        }
        // Deep link: Opens app to Verse Library
        .widgetURL(URL(string: "edcfaith://verse/daily")!)
    }
}

// MARK: - Widget Configuration
struct VerseWidget: Widget {
    let kind: String = "VerseWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: VerseProvider()) { entry in
            VerseWidgetView(entry: entry)
        }
        // Localized widget name and description
        .configurationDisplayName(NSLocalizedString("verseOfTheDay", comment: "Verse of the Day widget title"))
        .description(NSLocalizedString("widgetDescription", comment: "Daily inspirational Bible verse on your home screen."))
        .supportedFamilies([.systemMedium]) // 4x2 size only
    }
}

// MARK: - Preview
struct VerseWidget_Previews: PreviewProvider {
    static var previews: some View {
        VerseWidgetView(entry: VerseEntry(
            date: Date(),
            verseText: "For God so loved the world that he gave his one and only Son, that whoever believes in him shall not perish but have eternal life.",
            verseReference: "John 3:16",
            verseTranslation: "KJV"
        ))
        .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
