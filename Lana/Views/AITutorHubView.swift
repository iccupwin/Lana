import SwiftUI

// MARK: - AI Tutor Hub

struct AITutorHubView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    private let modes: [(icon: String, title: String, subtitle: String, xp: String, gradient: LinearGradient)] = [
        ("bubble.left.fill",        "Free Talk",      "Chat about anything",     "+15 XP", DarkDS.blueGradient),
        ("text.bubble.fill",        "Topic Chat",     "Choose a topic",          "+20 XP", DarkDS.purpleGradient),
        ("waveform.circle.fill",    "Speaking",       "Pronunciation drills",    "+25 XP", DarkDS.limeGradient),
        ("pencil.line",             "Writing",        "Get AI feedback",         "+30 XP", DarkDS.orangeGradient)
    ]

    private let topics = AITutorTopic.all

    var body: some View {
        DarkScreen {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    header
                    dailyChallengeCard
                    modesGrid
                    topicsSection
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 110)
            }
        }
    }

    // MARK: Header

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("AI Coach")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(LotusApp.ink)
                Text("Practice makes perfect")
                    .font(.system(size: 14))
                    .foregroundStyle(DarkDS.muted)
            }
            Spacer()
            ZStack {
                Circle()
                    .fill(DarkDS.lime.opacity(0.15))
                    .frame(width: 52, height: 52)
                Image(systemName: "cpu.fill")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(DarkDS.lime)
            }
        }
        .padding(.top, 16)
    }

    // MARK: Daily Challenge

    private var dailyChallengeCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white)
                Text("DAILY CHALLENGE")
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .tracking(1.2)
                Spacer()
                Text("+50 XP")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.6))
                    .padding(.horizontal, 8).padding(.vertical, 3)
                    .background(Capsule().fill(.black.opacity(0.12)))
            }

            Text(dailyChallenge)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)

            NavigationLink {
                FreeTalkView(
                    topic: "Daily Challenge",
                    prompt: dailyChallenge
                ).environmentObject(appState)
            } label: {
                HStack {
                    Text("Start challenge")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Spacer()
                    Image(systemName: "arrow.right")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.white)
                }
                .padding(.horizontal, 16).padding(.vertical, 12)
                .background(RoundedRectangle(cornerRadius: 12).fill(.black.opacity(0.12)))
            }
            .buttonStyle(.plain)
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: DarkDS.r).fill(DarkDS.lime))
    }

    private var dailyChallenge: String {
        let challenges = [
            "Describe your perfect weekend in 3 sentences",
            "Talk about a skill you want to learn",
            "Explain what you did yesterday",
            "Describe your hometown to a stranger",
            "Tell about your favourite movie"
        ]
        let day = Calendar.current.component(.day, from: Date())
        return challenges[day % challenges.count]
    }

    // MARK: Modes Grid

    private var modesGrid: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Practice modes")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(LotusApp.ink)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                ForEach(modes.indices, id: \.self) { i in
                    let m = modes[i]
                    NavigationLink {
                        modeDestination(index: i)
                    } label: {
                        modeCard(m)
                    }
                    .buttonStyle(PressScaleStyle())
                }
            }
        }
    }

    private func modeCard(_ m: (icon: String, title: String, subtitle: String, xp: String, gradient: LinearGradient)) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(m.gradient)
                        .frame(width: 44, height: 44)
                    Image(systemName: m.icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(LotusApp.ink)
                }
                Spacer()
                Text(m.xp)
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundStyle(DarkDS.muted)
                    .padding(.horizontal, 7).padding(.vertical, 3)
                    .background(Capsule().fill(DarkDS.card2))
            }
            Text(m.title)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(LotusApp.ink)
            Text(m.subtitle)
                .font(.system(size: 12))
                .foregroundStyle(DarkDS.muted)
                .lineLimit(1)
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 18).fill(DarkDS.card))
    }

    @ViewBuilder
    private func modeDestination(index: Int) -> some View {
        switch index {
        case 0:
            FreeTalkView(topic: "Free Talk", prompt: "Hi! I'm your AI English coach. What would you like to talk about today?")
                .environmentObject(appState)
        case 1:
            TopicChatPickerView().environmentObject(appState)
        case 2:
            SpeakingPracticeView().environmentObject(appState)
        case 3:
            WritingCheckView().environmentObject(appState)
        default:
            EmptyView()
        }
    }

    // MARK: Topics Section

    private var topicsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Popular topics")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(LotusApp.ink)

            VStack(spacing: 10) {
                ForEach(topics) { topic in
                    NavigationLink {
                        FreeTalkView(
                            topic: topic.title,
                            prompt: topic.openingMessage
                        ).environmentObject(appState)
                    } label: {
                        topicRow(topic)
                    }
                    .buttonStyle(PressScaleStyle())
                }
            }
        }
    }

    private func topicRow(_ topic: AITutorTopic) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(topic.color.opacity(0.18))
                    .frame(width: 48, height: 48)
                Image(systemName: topic.icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(topic.color)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(topic.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(LotusApp.ink)
                Text(topic.subtitle)
                    .font(.system(size: 12))
                    .foregroundStyle(DarkDS.muted)
            }
            Spacer()
            HStack(spacing: 6) {
                Text(topic.level)
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundStyle(topic.color)
                    .padding(.horizontal, 8).padding(.vertical, 3)
                    .background(Capsule().fill(topic.color.opacity(0.15)))
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(DarkDS.muted)
            }
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 16).fill(DarkDS.card))
    }
}

// MARK: - Topic Picker

struct TopicChatPickerView: View {
    @EnvironmentObject private var appState: AppState
    var body: some View {
        DarkScreen {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        DarkBackButton()
                        Text("Choose topic").font(.system(size: 22, weight: .bold)).foregroundStyle(LotusApp.ink)
                        Spacer()
                    }
                    .padding(.horizontal, 20).padding(.top, 16)

                    VStack(spacing: 10) {
                        ForEach(AITutorTopic.all) { topic in
                            NavigationLink {
                                FreeTalkView(topic: topic.title, prompt: topic.openingMessage)
                                    .environmentObject(appState)
                            } label: {
                                HStack(spacing: 14) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(topic.color.opacity(0.18))
                                            .frame(width: 48, height: 48)
                                        Image(systemName: topic.icon)
                                            .font(.system(size: 20, weight: .semibold))
                                            .foregroundStyle(topic.color)
                                    }
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(topic.title).font(.system(size: 15, weight: .semibold)).foregroundStyle(LotusApp.ink)
                                        Text(topic.subtitle).font(.system(size: 12)).foregroundStyle(DarkDS.muted)
                                    }
                                    Spacer()
                                    Text(topic.level)
                                        .font(.system(size: 10, weight: .bold, design: .rounded))
                                        .foregroundStyle(topic.color)
                                        .padding(.horizontal, 8).padding(.vertical, 3)
                                        .background(Capsule().fill(topic.color.opacity(0.15)))
                                }
                                .padding(14)
                                .background(RoundedRectangle(cornerRadius: 16).fill(DarkDS.card))
                            }
                            .buttonStyle(PressScaleStyle())
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 110)
            }
        }
    }
}

// MARK: - Speaking Practice (dark wrapper)

struct SpeakingPracticeView: View {
    @EnvironmentObject private var appState: AppState
    var body: some View {
        PronunciationPracticeView(sqliteService: appState.sqliteService)
            .environmentObject(appState)
    }
}

// MARK: - Data Model

struct AITutorTopic: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let level: String
    let openingMessage: String

    static let all: [AITutorTopic] = [
        AITutorTopic(id: "job",      title: "Job Interview",   subtitle: "Ace your next interview",   icon: "briefcase.fill",      color: DarkDS.lime,                                    level: "B1",  openingMessage: "Let's practice for a job interview! I'll be the interviewer. First question: Tell me about yourself."),
        AITutorTopic(id: "travel",   title: "Travel & Places", subtitle: "Describe destinations",     icon: "airplane",             color: Color(red: 0.22, green: 0.44, blue: 0.98),      level: "A2",  openingMessage: "Let's talk about travel! Have you visited any interesting places recently? Tell me about one of your favourite destinations."),
        AITutorTopic(id: "food",     title: "Food & Cooking",  subtitle: "Talk about cuisine",        icon: "fork.knife",           color: Color(red: 0.98, green: 0.60, blue: 0.18),      level: "A1",  openingMessage: "I love talking about food! What's your favourite meal? Do you enjoy cooking at home?"),
        AITutorTopic(id: "tech",     title: "Technology",      subtitle: "Discuss the digital world", icon: "cpu.fill",             color: Color(red: 0.62, green: 0.38, blue: 0.98),      level: "B2",  openingMessage: "Technology is changing so fast! What do you think is the most important technological innovation of the last decade?"),
        AITutorTopic(id: "health",   title: "Health & Sport",  subtitle: "Healthy lifestyle tips",    icon: "heart.fill",           color: Color(red: 0.98, green: 0.30, blue: 0.30),      level: "A2",  openingMessage: "How do you stay healthy? Do you exercise regularly or have a special diet?"),
        AITutorTopic(id: "culture",  title: "Culture & Art",   subtitle: "Films, music, books",       icon: "theatermasks.fill",    color: Color(red: 0.20, green: 0.78, blue: 0.43),      level: "B1",  openingMessage: "Let's talk about culture! What kind of music do you like? Have you seen any great films recently?"),
        AITutorTopic(id: "smalltalk", title: "Small Talk",     subtitle: "Master casual English",     icon: "person.2.fill",        color: Color(red: 0.98, green: 0.79, blue: 0.20),      level: "A1",  openingMessage: "Let's practice small talk — the kind of friendly chat you'd have with a new colleague or neighbour. How's your day going?"),
        AITutorTopic(id: "business", title: "Business English", subtitle: "Meetings & presentations", icon: "chart.line.uptrend.xyaxis", color: Color(red: 0.22, green: 0.44, blue: 0.98), level: "B2",  openingMessage: "Let's practice business English. Imagine you need to present your project results to the management team. Start with an introduction.")
    ]
}
