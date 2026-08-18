import SwiftUI

struct StoriesView: View {
    @StateObject private var viewModel: StoriesViewModel
    @EnvironmentObject private var appState: AppState

    init(repository: ContentRepository, sqliteService: SQLiteService) {
        _viewModel = StateObject(wrappedValue: StoriesViewModel(repository: repository, sqliteService: sqliteService))
    }

    var body: some View {
        DarkScreen {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(alignment: .leading, spacing: 16) {
                    pageHeader
                    LotusCollectionHero(
                        imageName: "LotusLanguageBook",
                        title: "Read into the language",
                        subtitle: "Stories turn new words into something memorable",
                        height: 178
                    )
                    LotusSectionTitle(title: "Story library", trailing: "\(viewModel.stories.count) stories")
                    LazyVStack(spacing: 10) {
                        ForEach(viewModel.stories) { story in
                            NavigationLink {
                                StoryReaderView(
                                    viewModel: StoryReaderViewModel(story: story, sqliteService: appState.sqliteService)
                                )
                                .environmentObject(appState)
                            } label: {
                                storyCard(story)
                            }
                            .buttonStyle(PressScaleStyle())
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 110)
            }
        }
        .navigationBarHidden(true)
        .onAppear { viewModel.load() }
    }

    private var pageHeader: some View {
        LotusDetailHeader(
            title: "Stories",
            subtitle: "Read and learn",
            icon: "books.vertical.fill",
            color: LotusApp.amber
        )
    }

    private func storyCard(_ story: Story) -> some View {
        let done = viewModel.isCompleted(story)
        let color = Color(hex: story.colorHex)
        return HStack(spacing: 14) {
            LotusIconBadge(icon: story.iconSystemName, color: done ? LotusApp.subtle : color, size: 52)

            VStack(alignment: .leading, spacing: 4) {
                Text(story.title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(done ? LotusApp.muted : LotusApp.ink)
                Text(story.subtitle)
                    .font(.system(size: 11, design: .rounded))
                    .foregroundStyle(LotusApp.muted)
                HStack(spacing: 6) {
                    LotusStatusPill(text: story.cefrLevel, color: done ? LotusApp.muted : color)
                    if !done {
                        LotusStatusPill(text: "+40 XP", color: LotusApp.cobalt, icon: "bolt.fill")
                    }
                }
                .padding(.top, 2)
            }

            Spacer(minLength: 0)

            Image(systemName: done ? "checkmark.circle.fill" : "chevron.right")
                .font(.system(size: done ? 20 : 13, weight: .semibold))
                .foregroundStyle(done ? LotusApp.mint : LotusApp.subtle)
        }
        .padding(14)
        .lotusGlassCard(cornerRadius: 19, opacity: 0.80, shadow: 0.045)
    }
}
