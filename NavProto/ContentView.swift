//
//  ContentView.swift
//  NavProto
//
//  Created by Gnascimento on 11/03/2026.
//

import NavigatorUI
import SwiftUI

struct ContentView: View {
    @State private var selectedTab: AppTab = .today

    var body: some View {
        TabView(selection: $selectedTab) {
            ArticleFeedView(
                tab: .today,
                title: "Top Stories",
                stackName: "top-stories",
                articles: Article.sampleTopStories
            )
            .tabItem {
                Label("Today", systemImage: "newspaper")
            }
            .tag(AppTab.today)

            ArticleFeedView(
                tab: .tech,
                title: "Technology",
                stackName: "technology",
                articles: Article.sampleTechnology
            )
            .tabItem {
                Label("Tech", systemImage: "desktopcomputer")
            }
            .tag(AppTab.tech)

            ArticleFeedView(
                tab: .saved,
                title: "Saved Reads",
                stackName: "saved-reads",
                articles: Article.sampleSaved
            )
            .tabItem {
                Label("Saved", systemImage: "bookmark")
            }
            .tag(AppTab.saved)
        }
        .onNavigationReceive(assign: $selectedTab, delay: 0.5)
    }
}

private struct ArticleFeedView: View {
    let tab: AppTab
    let title: String
    let stackName: String
    let articles: [Article]

    var body: some View {
        ManagedNavigationStack(name: stackName) { navigator in
            List {
                Section {
                    FeedDemoCard(
                        currentTab: tab,
                        onPresentFromRoot: {
                            navigator.root.navigate(to: AppDestination.briefing(tab: tab))
                        },
                        onSwitchTab: {
                            navigator.send(tab.secondaryDemoTab)
                        }
                    )
                    .listRowInsets(EdgeInsets(top: 12, leading: 20, bottom: 14, trailing: 20))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }

                ForEach(articles) { article in
                    ArticleRow(article: article) {
                        navigator.navigate(to: ArticleDestination.article(article))
                    }
                    .listRowInsets(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
            }
            .listStyle(.plain)
            .navigationTitle(title)
        }
    }
}

private struct FeedDemoCard: View {
    let currentTab: AppTab
    let onPresentFromRoot: () -> Void
    let onSwitchTab: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Navigator demos")
                .font(.headline)

            Text("These buttons use the shared app navigator instead of only the current tab stack.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button(action: onPresentFromRoot) {
                demoButtonLabel(
                    title: "Present from app root",
                    subtitle: "Opens a managed sheet from the root navigator."
                )
            }
            .buttonStyle(.plain)

            Button(action: onSwitchTab) {
                demoButtonLabel(
                    title: "Switch to \(currentTab.secondaryDemoTab.title)",
                    subtitle: "Broadcasts a tab selection through navigator.send(...)."
                )
            }
            .buttonStyle(.plain)
        }
        .padding(18)
        .background {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.quaternary.opacity(0.45))
        }
    }

    @ViewBuilder
    private func demoButtonLabel(title: String, subtitle: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)

                Text(subtitle)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "arrow.right.circle.fill")
                .font(.title3)
                .foregroundStyle(.blue)
        }
        .padding(14)
        .background {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.background)
        }
    }
}

private struct ArticleRow: View {
    let article: Article
    let onOpenArticle: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: onOpenArticle) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(article.section.uppercased())
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(article.tint.color)

                        Spacer()

                        Text(article.readTime)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Text(article.title)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.leading)

                    Text(article.summary)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            HStack {
                NavigationLink(to: ArticleDestination.author(article.authorProfile)) {
                    Label(article.author, systemImage: "person.crop.circle")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)

                Spacer()

                Image(systemName: "arrow.up.right.circle.fill")
                    .font(.title3)
                    .foregroundStyle(article.tint.color)
            }
        }
        .padding(18)
        .background {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(article.tint.color.opacity(0.12))
        }
    }
}

private struct ArticleDetailView: View {
    @Environment(\.navigator) private var navigator

    let article: Article

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                ZStack(alignment: .bottomLeading) {
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [article.tint.color.opacity(0.95), article.tint.color.opacity(0.35)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 280)

                    VStack(alignment: .leading, spacing: 14) {
                        Text(article.section.uppercased())
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.white.opacity(0.85))

                        Text(article.title)
                            .font(.largeTitle.bold())
                            .foregroundStyle(.white)

                        Text("By \(article.author) • \(article.readTime)")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.85))
                    }
                    .padding(24)
                }

                Text(article.summary)
                    .font(.title3)
                    .foregroundStyle(.primary)

                ForEach(article.paragraphs, id: \.self) { paragraph in
                    Text(paragraph)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .lineSpacing(6)
                }
            }
            .padding(20)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") {
                    navigator.back()
                }
                .fontWeight(.semibold)
            }
        }
    }
}

private struct AuthorDetailView: View {
    let author: AuthorProfile

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [author.tint.color.opacity(0.9), author.tint.color.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 220)
                    .overlay(alignment: .bottomLeading) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(author.name)
                                .font(.largeTitle.bold())
                                .foregroundStyle(.white)

                            Text(author.role)
                                .font(.headline)
                                .foregroundStyle(.white.opacity(0.88))
                        }
                        .padding(24)
                    }

                Text(author.bio)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .lineSpacing(6)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Recent coverage")
                        .font(.headline)

                    ForEach(author.highlights, id: \.self) { highlight in
                        Label(highlight, systemImage: "newspaper.fill")
                            .foregroundStyle(.primary)
                    }
                }
            }
            .padding(20)
        }
        .navigationTitle(author.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct AppBriefingView: View {
    @Environment(\.navigator) private var navigator

    let tab: AppTab

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Root-level presentation")
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)

            Text("App-wide briefing")
                .font(.largeTitle.bold())

            Text("This sheet was presented by `navigator.root`, so it sits above the entire tab interface instead of belonging to just the \(tab.title) stack.")
                .font(.body)
                .foregroundStyle(.secondary)
                .lineSpacing(5)

            Button("Dismiss") {
                navigator.back()
            }
            .buttonStyle(.borderedProminent)

            Spacer()
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .navigationTitle("Briefing")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct Article: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let section: String
    let author: String
    let readTime: String
    let summary: String
    let paragraphs: [String]
    let tint: ArticleTint
}

private struct AuthorProfile: Hashable, Identifiable {
    let name: String
    let role: String
    let bio: String
    let highlights: [String]
    let tint: ArticleTint

    var id: String {
        name
    }
}

private enum AppTab: String, Hashable {
    case today
    case tech
    case saved
}

private extension AppTab {
    var title: String {
        switch self {
        case .today:
            "Today"
        case .tech:
            "Tech"
        case .saved:
            "Saved"
        }
    }

    var secondaryDemoTab: AppTab {
        switch self {
        case .today:
            .saved
        case .tech:
            .today
        case .saved:
            .tech
        }
    }
}

private enum ArticleTint: String, Hashable {
    case blue
    case green
    case orange
    case indigo
    case teal
    case mint
    case pink
    case red
}

private extension ArticleTint {
    var color: Color {
        switch self {
        case .blue:
            .blue
        case .green:
            .green
        case .orange:
            .orange
        case .indigo:
            .indigo
        case .teal:
            .teal
        case .mint:
            .mint
        case .pink:
            .pink
        case .red:
            .red
        }
    }
}

private enum ArticleDestination: Hashable {
    case article(Article)
    case author(AuthorProfile)
}

private enum AppDestination: Hashable {
    case briefing(tab: AppTab)
}

extension ArticleDestination: NavigationDestination {
    var body: some View {
        switch self {
        case .article(let article):
            ArticleDetailView(article: article)
        case .author(let author):
            AuthorDetailView(author: author)
        }
    }

    var method: NavigationMethod {
        switch self {
        case .article:
            .managedCover
        case .author:
            .push
        }
    }
}

extension AppDestination: NavigationDestination {
    var body: some View {
        switch self {
        case .briefing(let tab):
            AppBriefingView(tab: tab)
        }
    }

    var method: NavigationMethod {
        .managedSheet
    }

    var detents: Set<PresentationDetent> {
        [.medium, .large]
    }

    var selectedDetent: PresentationDetent? {
        .medium
    }
}

private extension Article {
    var authorProfile: AuthorProfile {
        switch author {
        case "Lina Ortiz":
            AuthorProfile(
                name: author,
                role: "Transit Correspondent",
                bio: "Lina covers the systems that keep cities moving, from ferries and commuter rail to the politics of late-night mobility.",
                highlights: [
                    "Midnight transit expansions and event crowd planning",
                    "Waterfront commuting patterns",
                    "Regional ferry modernization"
                ],
                tint: .blue
            )
        case "Mara Singh":
            AuthorProfile(
                name: author,
                role: "Climate Reporter",
                bio: "Mara reports on urban resilience projects with a focus on how public spaces are being redesigned for heat, flooding, and long-term livability.",
                highlights: [
                    "Pocket park climate pilots",
                    "Neighborhood cooling strategies",
                    "Green infrastructure funding"
                ],
                tint: .green
            )
        case "Evan Cole":
            AuthorProfile(
                name: author,
                role: "Culture Critic",
                bio: "Evan writes about the business and creative choices shaping games, film, and the wider entertainment industry.",
                highlights: [
                    "Studio strategy and sequel fatigue",
                    "Audience response to prestige game launches",
                    "How creators pace blockbuster production"
                ],
                tint: .orange
            )
        case "Noah Kim":
            AuthorProfile(
                name: author,
                role: "AI Editor",
                bio: "Noah tracks practical AI product decisions, especially where model behavior collides with battery limits, latency, and privacy constraints.",
                highlights: [
                    "On-device inference tradeoffs",
                    "Mobile AI product design",
                    "Runtime orchestration for constrained hardware"
                ],
                tint: .indigo
            )
        case "Gia Bennett":
            AuthorProfile(
                name: author,
                role: "Software Reporter",
                bio: "Gia covers interface trends, consumer software strategy, and the way old product ideas keep returning in new form.",
                highlights: [
                    "The browser as workspace",
                    "Sidebar design cycles",
                    "Product surface area in desktop software"
                ],
                tint: .teal
            )
        case "Felix Hart":
            AuthorProfile(
                name: author,
                role: "Hardware Analyst",
                bio: "Felix focuses on chips, supply chains, and how smaller hardware companies carve out narrow but defensible markets.",
                highlights: [
                    "Specialized silicon economics",
                    "Compute bottlenecks in enterprise tooling",
                    "Chip startup go-to-market strategy"
                ],
                tint: .mint
            )
        case "Tessa Moore":
            AuthorProfile(
                name: author,
                role: "Lifestyle Writer",
                bio: "Tessa reports on the quieter corners of city life, with a focus on spaces that reward lingering, reading, and routine.",
                highlights: [
                    "Cafe culture and work-friendly spaces",
                    "Weekend neighborhood guides",
                    "How hospitality design shapes behavior"
                ],
                tint: .pink
            )
        case "Amir Wells":
            AuthorProfile(
                name: author,
                role: "Urbanism Columnist",
                bio: "Amir writes about streets, transit, and the design choices that influence how cities feel after dark.",
                highlights: [
                    "Nighttime walkability",
                    "Storefront rhythm and pedestrian comfort",
                    "Transit frequency as public safety infrastructure"
                ],
                tint: .red
            )
        default:
            AuthorProfile(
                name: author,
                role: "Staff Writer",
                bio: "This reporter covers a range of stories across the desk.",
                highlights: ["Feature reporting", "Profiles", "Analysis"],
                tint: tint
            )
        }
    }

    static let sampleTopStories: [Article] = [
        Article(
            title: "City Ferries Add Midnight Routes for Summer Weekends",
            section: "Transit",
            author: "Lina Ortiz",
            readTime: "4 min read",
            summary: "A late-night expansion is meant to relieve bridge traffic and keep waterfront districts active after events.",
            paragraphs: [
                "The transit authority says three ferry lines will continue running until 1:30 a.m. on Fridays and Saturdays from June through September.",
                "Officials expect the added service to absorb some of the demand that typically spills onto ride-hailing apps after concerts and stadium events.",
                "Local businesses along the waterfront supported the move, arguing that easier return trips encourage residents to stay in the district longer."
            ],
            tint: .blue
        ),
        Article(
            title: "How Small Parks Are Becoming the Center of Neighborhood Climate Plans",
            section: "Environment",
            author: "Mara Singh",
            readTime: "6 min read",
            summary: "Pocket parks are being redesigned as cooling stations, flood buffers, and flexible public space all at once.",
            paragraphs: [
                "Urban planners are using small parcels of public land to test dense planting strategies and new water retention systems.",
                "Residents interviewed near recent pilot sites said the upgrades were most noticeable during heat waves, when shaded seating filled quickly.",
                "The next design phase will add public drinking fountains and evening lighting so the spaces remain useful beyond business hours."
            ],
            tint: .green
        ),
        Article(
            title: "The Studio Behind This Year's Surprise Hit Game Wants Slower Releases",
            section: "Culture",
            author: "Evan Cole",
            readTime: "5 min read",
            summary: "After a breakout launch, the team says it would rather ship fewer projects than chase annual sequel cycles.",
            paragraphs: [
                "Leadership at the studio described the current moment as a chance to reset expectations around output and production pace.",
                "Developers said the strongest feedback from players focused on craft and atmosphere rather than sheer volume of content.",
                "That response has made a slower roadmap easier to defend internally, even with commercial pressure building around the franchise."
            ],
            tint: .orange
        )
    ]

    static let sampleTechnology: [Article] = [
        Article(
            title: "Design Teams Are Treating On-Device AI Like a Battery Budget Problem",
            section: "AI",
            author: "Noah Kim",
            readTime: "7 min read",
            summary: "Product teams are balancing latency, privacy, and battery draw instead of assuming every feature belongs in the cloud.",
            paragraphs: [
                "Engineers building mobile AI features are increasingly measuring power use alongside inference quality and response speed.",
                "That shift is forcing design teams to choose where intelligence actually matters, rather than layering assistants onto every screen.",
                "Several startups now pitch their tooling less as model infrastructure and more as runtime orchestration for constrained devices."
            ],
            tint: .indigo
        ),
        Article(
            title: "Why Browser Makers Keep Revisiting the Sidebar",
            section: "Software",
            author: "Gia Bennett",
            readTime: "3 min read",
            summary: "The sidebar has returned as the preferred place for chat, tabs, notes, and every feature that doesn't fit the traditional toolbar.",
            paragraphs: [
                "The modern browser is absorbing workflow features that used to live in separate utilities and pinned desktop apps.",
                "A sidebar gives those tools space without forcing a full redesign of the core page canvas.",
                "The risk is obvious: once every experiment lands there, the browser starts to feel less like a viewer and more like an operating system."
            ],
            tint: .teal
        ),
        Article(
            title: "Chip Startups Are Pitching Custom Silicon for One Workflow at a Time",
            section: "Hardware",
            author: "Felix Hart",
            readTime: "8 min read",
            summary: "Instead of trying to beat general-purpose processors, new entrants are optimizing around a single expensive task.",
            paragraphs: [
                "Founders say the strongest demand comes from companies with one bottleneck that dominates compute costs for the entire business.",
                "That leads to narrower chips, smaller software surfaces, and customer conversations centered on payback period instead of benchmark scores.",
                "It is a pragmatic market position, but one that depends on proving the workflow will stay important for years rather than months."
            ],
            tint: .mint
        )
    ]

    static let sampleSaved: [Article] = [
        Article(
            title: "A Sunday Guide to the City's Quietest Cafes",
            section: "Lifestyle",
            author: "Tessa Moore",
            readTime: "4 min read",
            summary: "Nine spots where the music stays low, the tables are large, and nobody minds if you bring a notebook.",
            paragraphs: [
                "The best quiet cafes share a few traits: deep seating, long sight lines, and enough ambient movement to feel alive without becoming noisy.",
                "Owners say the calm atmosphere is intentional and often protected by limiting speaker volume and avoiding high-turnover layouts.",
                "Several of the cafes on this list also extend into bookstores or plant shops, which helps soften the acoustics even further."
            ],
            tint: .pink
        ),
        Article(
            title: "What Makes a Good Walking City After Dark",
            section: "Urbanism",
            author: "Amir Wells",
            readTime: "5 min read",
            summary: "Lighting, storefront rhythm, and transit frequency matter more than landmark architecture once offices empty out.",
            paragraphs: [
                "Researchers studying pedestrian comfort point out that people respond to predictable activity as much as visual beauty.",
                "A lively corridor tends to mix practical destinations with enough transparency at street level to reduce uncertainty.",
                "Late-evening transit service then determines whether walking feels connected to the rest of the city or isolated from it."
            ],
            tint: .red
        )
    ]
}

#Preview {
    ContentView()
}
