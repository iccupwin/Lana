import SwiftUI

struct VocabTopicsView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    private let topics: [VocabTopic] = VocabTopicsView.builtInTopics
    @State private var selected: VocabTopic? = nil

    var body: some View {
        DarkScreen {
            ZStack {
                if let topic = selected {
                    topicDetailView(topic)
                        .transition(.opacity.combined(with: .move(edge: .trailing)))
                } else {
                    topicListView
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selected?.id)
        }
        .navigationBarHidden(true)
    }

    // MARK: - Topic Grid

    private var topicListView: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                topicListHeader
                LazyVGrid(
                    columns: [GridItem(.flexible()), GridItem(.flexible())],
                    spacing: 14
                ) {
                    ForEach(topics) { topic in
                        Button { selected = topic } label: {
                            topicCard(topic)
                        }
                        .buttonStyle(PressScaleStyle())
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 110)
        }
    }

    private var topicListHeader: some View {
        HStack {
            DarkBackButton()
            Text("Vocabulary Topics")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(LotusApp.ink)
            Spacer()
        }
        .padding(.top, 16)
    }

    private func topicCard(_ topic: VocabTopic) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: topic.colorHex).opacity(0.22))
                    .frame(width: 48, height: 48)
                Image(systemName: topic.icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(Color(hex: topic.colorHex))
            }
            Spacer(minLength: 4)
            Text(topic.title)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(LotusApp.ink)
            Text("\(topic.words.count) words")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(DarkDS.muted)
        }
        .frame(maxWidth: .infinity, minHeight: 120, alignment: .leading)
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 20).fill(DarkDS.card))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(Color(hex: topic.colorHex).opacity(0.25), lineWidth: 1)
        )
    }

    // MARK: - Topic Detail

    private func topicDetailView(_ topic: VocabTopic) -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                topicDetailHeader(topic)
                saveAllButton(topic)
                ForEach(topic.words) { word in
                    wordRow(word, topicColor: topic.colorHex)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 110)
        }
    }

    private func topicDetailHeader(_ topic: VocabTopic) -> some View {
        HStack(spacing: 14) {
            Button { withAnimation { selected = nil } } label: {
                ZStack {
                    Circle().fill(DarkDS.card2).frame(width: 38, height: 38)
                    Image(systemName: "chevron.left")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(LotusApp.ink)
                }
            }
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(hex: topic.colorHex).opacity(0.22))
                    .frame(width: 38, height: 38)
                Image(systemName: topic.icon)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color(hex: topic.colorHex))
            }
            Text(topic.title)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(LotusApp.ink)
            Spacer()
        }
        .padding(.top, 16)
    }

    private func saveAllButton(_ topic: VocabTopic) -> some View {
        Button {
            for w in topic.words {
                appState.sqliteService.saveWord(
                    Word(id: w.id, word: w.word, phonetic: "", translation: w.translation,
                         example: w.example, dayIndex: 0, register: nil, cefr: nil, collocations: nil)
                )
            }
            appState.awardXPOnce(key: "topic_\(topic.id)", amount: 10)
            QuestService.shared.updateQuestProgress(type: .saveWords, increment: topic.words.count)
            HapticService.shared.notify(.success)
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "bookmark.fill")
                    .font(.system(size: 14))
                Text("Save All \(topic.words.count) Words")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(RoundedRectangle(cornerRadius: 14).fill(Color(hex: topic.colorHex)))
        }
        .buttonStyle(PressScaleStyle())
    }

    private func wordRow(_ w: TopicWord, topicColor: String) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 5) {
                Text(w.word)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(LotusApp.ink)
                Text(w.translation)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(DarkDS.muted)
                Text(w.example)
                    .font(.system(size: 12))
                    .foregroundStyle(DarkDS.muted.opacity(0.7))
                    .italic()
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
            Button {
                appState.sqliteService.saveWord(
                    Word(id: w.id, word: w.word, phonetic: "", translation: w.translation,
                         example: w.example, dayIndex: 0, register: nil, cefr: nil, collocations: nil)
                )
                appState.awardXPOnce(key: "word_\(w.id)", amount: 2)
                QuestService.shared.updateQuestProgress(type: .saveWords)
                HapticService.shared.selection()
            } label: {
                Image(systemName: "bookmark.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(Color(hex: topicColor))
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16).fill(DarkDS.card))
    }

    // MARK: - Built-in Topic Data

    static let builtInTopics: [VocabTopic] = [
        VocabTopic(id: "food", title: "Food & Drink", icon: "fork.knife", colorHex: "#C5F132", words: [
            TopicWord(id: "t_food_1", word: "appetizer",  translation: "закуска",      example: "We ordered an appetizer before the main course."),
            TopicWord(id: "t_food_2", word: "beverage",   translation: "напиток",      example: "What beverage would you like with your meal?"),
            TopicWord(id: "t_food_3", word: "cuisine",    translation: "кухня",        example: "Italian cuisine is famous worldwide."),
            TopicWord(id: "t_food_4", word: "ingredient", translation: "ингредиент",   example: "The key ingredient is fresh basil."),
            TopicWord(id: "t_food_5", word: "recipe",     translation: "рецепт",       example: "She followed the recipe carefully."),
            TopicWord(id: "t_food_6", word: "portion",    translation: "порция",       example: "The portion was huge — I couldn't finish it."),
            TopicWord(id: "t_food_7", word: "sip",        translation: "глоток",       example: "She took a sip of her coffee."),
            TopicWord(id: "t_food_8", word: "savoury",    translation: "пикантный",    example: "I prefer savoury food over sweet."),
        ]),
        VocabTopic(id: "travel", title: "Travel", icon: "airplane", colorHex: "#5B8FFF", words: [
            TopicWord(id: "t_travel_1", word: "itinerary",     translation: "маршрут",              example: "Our itinerary includes three cities."),
            TopicWord(id: "t_travel_2", word: "departure",     translation: "вылет",                example: "The departure is at 6 a.m."),
            TopicWord(id: "t_travel_3", word: "landmark",      translation: "достопримечательность", example: "Big Ben is London's most famous landmark."),
            TopicWord(id: "t_travel_4", word: "accommodation", translation: "жильё",                example: "We need to book accommodation in advance."),
            TopicWord(id: "t_travel_5", word: "customs",       translation: "таможня",              example: "We had to go through customs at the airport."),
            TopicWord(id: "t_travel_6", word: "souvenir",      translation: "сувенир",              example: "I bought a souvenir for my family."),
            TopicWord(id: "t_travel_7", word: "layover",       translation: "пересадка",            example: "We had a 3-hour layover in Dubai."),
            TopicWord(id: "t_travel_8", word: "jet lag",       translation: "джетлаг",              example: "I suffered from jet lag after the long flight."),
        ]),
        VocabTopic(id: "work", title: "Work & Career", icon: "briefcase.fill", colorHex: "#4CD97B", words: [
            TopicWord(id: "t_work_1", word: "deadline",    translation: "дедлайн",        example: "The deadline for the project is Friday."),
            TopicWord(id: "t_work_2", word: "promotion",   translation: "повышение",       example: "She received a promotion after six months."),
            TopicWord(id: "t_work_3", word: "colleague",   translation: "коллега",         example: "My colleague helped me prepare the report."),
            TopicWord(id: "t_work_4", word: "resignation", translation: "увольнение",      example: "He submitted his resignation letter."),
            TopicWord(id: "t_work_5", word: "salary",      translation: "зарплата",        example: "We discussed the salary during the interview."),
            TopicWord(id: "t_work_6", word: "remote",      translation: "удалённый",       example: "I prefer working remote."),
            TopicWord(id: "t_work_7", word: "meeting",     translation: "встреча",         example: "We have a team meeting every Monday."),
            TopicWord(id: "t_work_8", word: "feedback",    translation: "обратная связь",  example: "Could you give me feedback on my presentation?"),
        ]),
        VocabTopic(id: "health", title: "Health & Body", icon: "heart.fill", colorHex: "#FF6B6B", words: [
            TopicWord(id: "t_health_1", word: "symptom",      translation: "симптом",          example: "A headache is a common symptom of stress."),
            TopicWord(id: "t_health_2", word: "prescription", translation: "рецепт",           example: "The doctor gave me a prescription for antibiotics."),
            TopicWord(id: "t_health_3", word: "appointment",  translation: "приём",            example: "I have a doctor's appointment at 3 p.m."),
            TopicWord(id: "t_health_4", word: "treatment",    translation: "лечение",          example: "The treatment lasts for two weeks."),
            TopicWord(id: "t_health_5", word: "recovery",     translation: "восстановление",   example: "His recovery was faster than expected."),
            TopicWord(id: "t_health_6", word: "surgery",      translation: "операция",         example: "She had surgery on her knee."),
            TopicWord(id: "t_health_7", word: "allergy",      translation: "аллергия",         example: "I have an allergy to peanuts."),
            TopicWord(id: "t_health_8", word: "diagnosis",    translation: "диагноз",          example: "The doctor made a diagnosis after the tests."),
        ]),
        VocabTopic(id: "emotions", title: "Emotions", icon: "face.smiling.fill", colorHex: "#FF9FCA", words: [
            TopicWord(id: "t_emo_1", word: "anxious",     translation: "тревожный",      example: "I felt anxious before the exam."),
            TopicWord(id: "t_emo_2", word: "overwhelmed", translation: "подавленный",    example: "She felt overwhelmed with work."),
            TopicWord(id: "t_emo_3", word: "relieved",    translation: "облегчённый",    example: "I was relieved when I passed the test."),
            TopicWord(id: "t_emo_4", word: "frustrated",  translation: "раздражённый",   example: "He was frustrated by the delay."),
            TopicWord(id: "t_emo_5", word: "content",     translation: "довольный",      example: "She felt content with her decision."),
            TopicWord(id: "t_emo_6", word: "nostalgic",   translation: "ностальгический",example: "The music made me feel nostalgic."),
            TopicWord(id: "t_emo_7", word: "ecstatic",    translation: "в восторге",     example: "She was ecstatic about the promotion."),
            TopicWord(id: "t_emo_8", word: "melancholy",  translation: "меланхолия",     example: "There was a sense of melancholy in his voice."),
        ]),
        VocabTopic(id: "tech", title: "Technology", icon: "cpu.fill", colorHex: "#9F7FFF", words: [
            TopicWord(id: "t_tech_1", word: "algorithm", translation: "алгоритм",                example: "The algorithm sorts data efficiently."),
            TopicWord(id: "t_tech_2", word: "bandwidth", translation: "пропускная способность",  example: "High bandwidth is needed for video calls."),
            TopicWord(id: "t_tech_3", word: "encrypt",   translation: "шифровать",               example: "The app encrypts your messages."),
            TopicWord(id: "t_tech_4", word: "interface", translation: "интерфейс",               example: "The interface is user-friendly."),
            TopicWord(id: "t_tech_5", word: "software",  translation: "программное обеспечение", example: "We need to update the software."),
            TopicWord(id: "t_tech_6", word: "database",  translation: "база данных",             example: "The database stores millions of records."),
            TopicWord(id: "t_tech_7", word: "prototype", translation: "прототип",                example: "They built a prototype in two weeks."),
            TopicWord(id: "t_tech_8", word: "debug",     translation: "отлаживать",              example: "It took hours to debug the code."),
        ]),
    ]
}
