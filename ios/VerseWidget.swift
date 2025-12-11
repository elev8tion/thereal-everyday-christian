import WidgetKit
import SwiftUI

// MARK: - Verse Model
struct VerseEntry: TimelineEntry {
    let date: Date
    let verse: String
    let reference: String
    let spanish: String
    let spanishReference: String
}

// MARK: - Timeline Provider
struct VerseProvider: TimelineProvider {
    func placeholder(in context: Context) -> VerseEntry {
        VerseEntry(
            date: Date(),
            verse: "For God so loved the world that he gave his one and only Son...",
            reference: "John 3:16",
            spanish: "Porque de tal manera amó Dios al mundo...",
            spanishReference: "Juan 3:16"
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (VerseEntry) -> ()) {
        let entry = loadVerse()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<VerseEntry>) -> ()) {
        let entry = loadVerse()

        // Update at midnight tomorrow
        let midnight = Calendar.current.startOfDay(for: Date().addingTimeInterval(86400))
        let timeline = Timeline(entries: [entry], policy: .after(midnight))

        completion(timeline)
    }

    private func loadVerse() -> VerseEntry {
        // Load from UserDefaults shared with main app
        let sharedDefaults = UserDefaults(suiteName: "group.com.edcfaith.shared")

        let verse = sharedDefaults?.string(forKey: "daily_verse_text") ?? "Trust in the LORD with all your heart and lean not on your own understanding."
        let reference = sharedDefaults?.string(forKey: "daily_verse_reference") ?? "Proverbs 3:5"
        let spanish = sharedDefaults?.string(forKey: "daily_verse_spanish_text") ?? "Confía en el SEÑOR con todo tu corazón y no te apoyes en tu propio entendimiento."
        let spanishReference = sharedDefaults?.string(forKey: "daily_verse_spanish_reference") ?? "Proverbios 3:5"

        return VerseEntry(
            date: Date(),
            verse: verse,
            reference: reference,
            spanish: spanish,
            spanishReference: spanishReference
        )
    }
}

// MARK: - Widget View with Glassmorphic Design
struct VerseWidgetView: View {
    var entry: VerseProvider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        ZStack {
            // Background gradient (matches your app theme)
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.15),
                    Color(red: 0.1, green: 0.1, blue: 0.2)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Glassmorphic container
            VStack(spacing: 0) {
                // Header with logo and title
                HStack(spacing: 8) {
                    // Gold-bordered logo (glassmorphic FAB style)
                    ZStack {
                        // Glass background
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.1))
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.ultraThinMaterial)
                            )

                        // Gold border
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.85, green: 0.65, blue: 0.13),
                                        Color(red: 1.0, green: 0.84, blue: 0.0)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )

                        // Logo
                        Image("AppLogo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                    }
                    .frame(width: 32, height: 32)

                    Text("Verse of the Day")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white.opacity(0.9))

                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 12)

                // Main content
                if family == .systemSmall {
                    smallWidgetContent
                } else {
                    mediumWidgetContent
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.05))
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.ultraThinMaterial)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
            .padding(16)
        }
        .widgetURL(URL(string: "edcfaith://verse-of-day"))
    }

    // Small widget layout
    var smallWidgetContent: some View {
        VStack(spacing: 8) {
            // Verse text (English only for space)
            Text(entry.verse)
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(.white)
                .lineLimit(4)
                .minimumScaleFactor(0.8)

            Spacer()

            // Reference
            Text(entry.reference)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(Color(red: 0.85, green: 0.65, blue: 0.13))
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }

    // Medium widget layout
    var mediumWidgetContent: some View {
        VStack(spacing: 12) {
            // English verse
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.verse)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.white)
                    .lineLimit(3)
                    .minimumScaleFactor(0.8)

                Text(entry.reference)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(red: 0.85, green: 0.65, blue: 0.13))
            }

            // Divider
            Rectangle()
                .fill(Color.white.opacity(0.2))
                .frame(height: 1)

            // Spanish verse
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.spanish)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(3)
                    .minimumScaleFactor(0.8)

                Text(entry.spanishReference)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(Color(red: 0.85, green: 0.65, blue: 0.13).opacity(0.8))
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
}

// MARK: - Widget Configuration
@main
struct VerseWidget: Widget {
    let kind: String = "VerseWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: VerseProvider()) { entry in
            VerseWidgetView(entry: entry)
        }
        .configurationDisplayName("Verse of the Day")
        .description("Daily scripture to inspire your faith journey")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Preview
struct VerseWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            VerseWidgetView(entry: VerseEntry(
                date: Date(),
                verse: "For God so loved the world that he gave his one and only Son, that whoever believes in him shall not perish but have eternal life.",
                reference: "John 3:16",
                spanish: "Porque de tal manera amó Dios al mundo, que ha dado a su Hijo unigénito, para que todo aquel que en él cree, no se pierda, mas tenga vida eterna.",
                spanishReference: "Juan 3:16"
            ))
            .previewContext(WidgetPreviewContext(family: .systemSmall))

            VerseWidgetView(entry: VerseEntry(
                date: Date(),
                verse: "Trust in the LORD with all your heart and lean not on your own understanding; in all your ways submit to him, and he will make your paths straight.",
                reference: "Proverbs 3:5-6",
                spanish: "Confía en el SEÑOR con todo tu corazón y no te apoyes en tu propio entendimiento. Reconócelo en todos tus caminos, y él enderezará tus sendas.",
                spanishReference: "Proverbios 3:5-6"
            ))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
        }
    }
}
