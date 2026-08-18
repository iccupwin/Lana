import SwiftUI

struct ListeningView: View {
    @ObservedObject var viewModel: ListeningViewModel
    var body: some View {
        DarkScreen {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(alignment: .leading, spacing: 16) {
                    pageHeader
                    LotusCollectionHero(
                        imageName: "LotusListeningRipple",
                        title: "Hear the shape of English",
                        subtitle: "Train your ear with clear, focused practice",
                        height: 176
                    )
                    LotusSectionTitle(title: "Listening sessions", trailing: "\(viewModel.exercises.count) exercises")
                    exerciseList
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
            title: "Listening",
            subtitle: "Tune in to natural English",
            icon: "waveform",
            color: LotusApp.aqua
        )
    }

    // MARK: List

    private var exerciseList: some View {
        LazyVStack(spacing: 10) {
            ForEach(viewModel.exercises) { exercise in
                NavigationLink {
                    ListeningDetailView(exercise: exercise)
                } label: {
                    exerciseRow(exercise)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func exerciseRow(_ exercise: ListeningExercise) -> some View {
        HStack(spacing: 14) {
            LotusIconBadge(icon: "headphones", color: LotusApp.aqua, size: 52)

            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(LotusApp.ink)
                Text(exercise.transcript.prefix(60) + "…")
                    .font(.system(size: 11, design: .rounded))
                    .foregroundStyle(LotusApp.muted)
                    .lineLimit(2)
                HStack(spacing: 8) {
                    LotusStatusPill(text: "\(exercise.questions.count) questions", color: LotusApp.muted, icon: "circle.grid.2x2")
                    LotusStatusPill(text: "Listen", color: LotusApp.aqua, icon: "play.fill")
                }
                .padding(.top, 2)
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(LotusApp.subtle)
        }
        .padding(14)
        .lotusGlassCard(cornerRadius: 19, opacity: 0.80, shadow: 0.045)
    }
}
