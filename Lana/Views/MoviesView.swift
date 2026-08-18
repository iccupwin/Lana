import SwiftUI

struct MoviesView: View {
    @ObservedObject var viewModel: MoviesViewModel
    private let accentColors: [Color] = [
        LotusApp.amber, LotusApp.violet, LotusApp.mint, LotusApp.coral,
        LotusApp.cobalt, LotusApp.aqua, LotusApp.violet, LotusApp.amber,
    ]

    var body: some View {
        DarkScreen {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(alignment: .leading, spacing: 16) {
                    pageHeader
                    LotusCollectionHero(
                        imageName: "LotusConversationOrbit",
                        title: "English in motion",
                        subtitle: "Learn through memorable scenes and natural dialogue",
                        height: 180
                    )
                    LotusSectionTitle(title: "Scene collection", trailing: "\(viewModel.scenes.count) scenes")
                    sceneList
                }
                .padding(.horizontal, 18)
                .padding(.top, 12)
                .padding(.bottom, 32)
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: Header

    private var pageHeader: some View {
        LotusDetailHeader(
            title: "Movie Lessons",
            subtitle: "Scenes and dialogue",
            icon: "film.fill",
            color: LotusApp.violet
        )
    }

    // MARK: List

    private var sceneList: some View {
        LazyVStack(spacing: 10) {
            ForEach(Array(viewModel.scenes.enumerated()), id: \.element.id) { i, scene in
                NavigationLink {
                    MovieDetailView(scene: scene)
                } label: {
                    sceneCard(scene: scene, index: i)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func sceneCard(scene: MovieScene, index: Int) -> some View {
        let color = accentColors[index % accentColors.count]
        return HStack(spacing: 14) {
            LotusIconBadge(icon: "film.fill", color: color, size: 52)

            VStack(alignment: .leading, spacing: 4) {
                Text(scene.movieTitle)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(LotusApp.ink)
                Text(scene.sceneTitle)
                    .font(.system(size: 11, design: .rounded))
                    .foregroundStyle(LotusApp.muted)
                    .lineLimit(2)
            }

            Spacer(minLength: 0)

            ZStack {
                Circle()
                    .fill(color.opacity(0.09))
                    .frame(width: 34, height: 34)
                Image(systemName: "play.fill")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(color)
            }
        }
        .padding(14)
        .lotusGlassCard(cornerRadius: 19, opacity: 0.80, shadow: 0.045)
    }
}
