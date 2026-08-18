import SwiftUI

// MARK: - Phrasebook View

struct PhrasebookView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var searchText   = ""
    @State private var selectedCat  = "All"
    @State private var savedIds: Set<String> = []

    private let categories = ["All", "Greetings", "Travel", "Business", "Emotions", "Daily Life", "Food", "Politeness", "Questions", "Time", "Numbers", "Emergency"]

    private var filtered: [Phrase] {
        Phrase.all.filter { p in
            (selectedCat == "All" || p.category == selectedCat) &&
            (searchText.isEmpty ||
             p.english.localizedCaseInsensitiveContains(searchText) ||
             p.translation.localizedCaseInsensitiveContains(searchText))
        }
    }

    var body: some View {
        DarkScreen {
            VStack(spacing: 0) {
                pageHeader
                searchBar
                categoryPills
                phraseList
            }
        }
    }

    // MARK: Header

    private var pageHeader: some View {
        HStack {
            DarkBackButton()
            VStack(alignment: .leading, spacing: 2) {
                Text("Phrasebook").font(.system(size: 20, weight: .bold)).foregroundStyle(LotusApp.ink)
                Text("\(Phrase.all.count) phrases").font(.system(size: 12)).foregroundStyle(DarkDS.muted)
            }
            Spacer()
        }
        .padding(.horizontal, 20).padding(.vertical, 14)
        .background(DarkDS.card.opacity(0.8))
        .overlay(Rectangle().fill(DarkDS.border).frame(height: 1), alignment: .bottom)
    }

    // MARK: Search Bar

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15))
                .foregroundStyle(DarkDS.muted)
            TextField("Search phrases...", text: $searchText)
                .font(.system(size: 14))
                .foregroundStyle(LotusApp.ink)
                .tint(DarkDS.lime)
            if !searchText.isEmpty {
                Button { searchText = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(DarkDS.muted)
                }
            }
        }
        .padding(.horizontal, 14).padding(.vertical, 11)
        .background(DarkDS.card, in: RoundedRectangle(cornerRadius: 14))
        .padding(.horizontal, 20).padding(.vertical, 12)
    }

    // MARK: Category Pills

    private var categoryPills: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(categories, id: \.self) { cat in
                    Button {
                        withAnimation(.spring(response: 0.3)) { selectedCat = cat }
                    } label: {
                        Text(cat)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(selectedCat == cat ? .white : LotusApp.muted)
                            .padding(.horizontal, 16).padding(.vertical, 8)
                            .background(
                                Capsule().fill(selectedCat == cat ? DarkDS.lime : DarkDS.card)
                            )
                            .overlay(
                                Capsule().strokeBorder(selectedCat == cat ? .clear : DarkDS.border, lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 10)
    }

    // MARK: Phrase List

    private var phraseList: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 10) {
                ForEach(filtered) { phrase in
                    phraseCard(phrase)
                }
                if filtered.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 36))
                            .foregroundStyle(DarkDS.muted)
                        Text("No phrases found")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(DarkDS.muted)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 60)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 110)
        }
    }

    private func phraseCard(_ phrase: Phrase) -> some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                Text(phrase.english)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(LotusApp.ink)
                Text(phrase.translation)
                    .font(.system(size: 13))
                    .foregroundStyle(DarkDS.muted)
                HStack(spacing: 6) {
                    Text(phrase.category)
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundStyle(DarkDS.lime)
                        .padding(.horizontal, 7).padding(.vertical, 2)
                        .background(Capsule().fill(DarkDS.lime.opacity(0.12)))
                    Text(phrase.level)
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundStyle(DarkDS.muted)
                }
            }
            Spacer()
            VStack(spacing: 12) {
                // TTS button
                Button {
                    TTSService.shared.speak(phrase.english)
                } label: {
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(Color(red: 0.22, green: 0.44, blue: 0.98))
                }
                // Save button
                Button {
                    withAnimation {
                        if savedIds.contains(phrase.id) {
                            savedIds.remove(phrase.id)
                        } else {
                            savedIds.insert(phrase.id)
                        }
                    }
                } label: {
                    Image(systemName: savedIds.contains(phrase.id) ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 16))
                        .foregroundStyle(savedIds.contains(phrase.id) ? DarkDS.lime : DarkDS.muted)
                }
            }
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 16).fill(DarkDS.card))
    }
}

// MARK: - Phrase Model

struct Phrase: Identifiable {
    let id: String
    let english: String
    let translation: String
    let category: String
    let level: String

    static let all: [Phrase] = greetings + travel + business + emotions + dailyLife + food + politeness + questions + emergency

    static let greetings: [Phrase] = [
        Phrase(id: "g1",  english: "Good morning, how are you?",         translation: "Доброе утро, как вы?",              category: "Greetings", level: "A1"),
        Phrase(id: "g2",  english: "Nice to meet you!",                  translation: "Приятно познакомиться!",             category: "Greetings", level: "A1"),
        Phrase(id: "g3",  english: "It's been a while!",                 translation: "Давно не виделись!",                 category: "Greetings", level: "A2"),
        Phrase(id: "g4",  english: "How have you been?",                 translation: "Как вы поживали?",                   category: "Greetings", level: "A2"),
        Phrase(id: "g5",  english: "Take care!",                         translation: "Берегите себя!",                     category: "Greetings", level: "A1"),
        Phrase(id: "g6",  english: "See you around.",                    translation: "До скорого.",                        category: "Greetings", level: "A1"),
        Phrase(id: "g7",  english: "What's up?",                         translation: "Как дела? (неформально)",           category: "Greetings", level: "A1"),
        Phrase(id: "g8",  english: "Long time no see!",                  translation: "Сколько лет, сколько зим!",          category: "Greetings", level: "A2")
    ]
    static let travel: [Phrase] = [
        Phrase(id: "t1",  english: "Could you show me on the map?",      translation: "Не могли бы вы показать на карте?",  category: "Travel", level: "A2"),
        Phrase(id: "t2",  english: "How far is it from here?",           translation: "Как далеко это отсюда?",             category: "Travel", level: "A2"),
        Phrase(id: "t3",  english: "Where is the nearest subway station?", translation: "Где ближайшая станция метро?",    category: "Travel", level: "A2"),
        Phrase(id: "t4",  english: "I'd like to book a room, please.",   translation: "Я бы хотел забронировать номер.",    category: "Travel", level: "A2"),
        Phrase(id: "t5",  english: "My flight has been delayed.",        translation: "Мой рейс задержан.",                 category: "Travel", level: "B1"),
        Phrase(id: "t6",  english: "Is breakfast included?",             translation: "Завтрак включён?",                  category: "Travel", level: "A2"),
        Phrase(id: "t7",  english: "Can I have a window seat, please?",  translation: "Можно место у окна?",               category: "Travel", level: "A2"),
        Phrase(id: "t8",  english: "What time does the museum open?",    translation: "Когда открывается музей?",           category: "Travel", level: "A2")
    ]
    static let business: [Phrase] = [
        Phrase(id: "b1",  english: "Let's get down to business.",        translation: "Перейдём к делу.",                   category: "Business", level: "B1"),
        Phrase(id: "b2",  english: "Could you elaborate on that?",       translation: "Не могли бы вы подробнее?",          category: "Business", level: "B2"),
        Phrase(id: "b3",  english: "I'll follow up with an email.",      translation: "Я напишу письмо после встречи.",     category: "Business", level: "B1"),
        Phrase(id: "b4",  english: "Let's schedule a meeting.",          translation: "Давайте назначим встречу.",           category: "Business", level: "B1"),
        Phrase(id: "b5",  english: "I'm afraid I have to disagree.",     translation: "Боюсь, я не согласен.",              category: "Business", level: "B2"),
        Phrase(id: "b6",  english: "To sum up our discussion…",          translation: "Подводя итог нашего обсуждения…",    category: "Business", level: "B2"),
        Phrase(id: "b7",  english: "Can we revisit this at a later stage?", translation: "Можем ли мы вернуться к этому позже?", category: "Business", level: "B2"),
        Phrase(id: "b8",  english: "That's outside the scope of this project.", translation: "Это выходит за рамки проекта.", category: "Business", level: "B2")
    ]
    static let emotions: [Phrase] = [
        Phrase(id: "e1",  english: "I'm really proud of you.",           translation: "Я очень горжусь тобой.",             category: "Emotions", level: "A2"),
        Phrase(id: "e2",  english: "I'm a bit under the weather.",       translation: "Я немного не в форме.",              category: "Emotions", level: "B1"),
        Phrase(id: "e3",  english: "That really means a lot to me.",     translation: "Это очень много значит для меня.",   category: "Emotions", level: "B1"),
        Phrase(id: "e4",  english: "I'm over the moon!",                 translation: "Я на седьмом небе!",                 category: "Emotions", level: "B1"),
        Phrase(id: "e5",  english: "That's a relief!",                   translation: "Вот облегчение!",                    category: "Emotions", level: "A2"),
        Phrase(id: "e6",  english: "I'm at a loss for words.",           translation: "У меня нет слов.",                   category: "Emotions", level: "B2")
    ]
    static let dailyLife: [Phrase] = [
        Phrase(id: "d1",  english: "Would you mind if I opened the window?", translation: "Вы не против, если я открою окно?", category: "Daily Life", level: "B1"),
        Phrase(id: "d2",  english: "Can you give me a hand?",           translation: "Можешь помочь мне?",                 category: "Daily Life", level: "A2"),
        Phrase(id: "d3",  english: "I'll be right back.",               translation: "Я скоро вернусь.",                   category: "Daily Life", level: "A1"),
        Phrase(id: "d4",  english: "Could you turn down the volume?",   translation: "Не могли бы вы убрать громкость?",   category: "Daily Life", level: "A2"),
        Phrase(id: "d5",  english: "Make yourself at home.",            translation: "Чувствуйте себя как дома.",          category: "Daily Life", level: "A2"),
        Phrase(id: "d6",  english: "I need to run some errands.",       translation: "Мне нужно сделать кое-какие дела.",  category: "Daily Life", level: "B1")
    ]
    static let food: [Phrase] = [
        Phrase(id: "f1",  english: "What do you recommend?",            translation: "Что вы рекомендуете?",               category: "Food", level: "A1"),
        Phrase(id: "f2",  english: "Could I get the bill, please?",     translation: "Счёт, пожалуйста.",                  category: "Food", level: "A1"),
        Phrase(id: "f3",  english: "I'm allergic to nuts.",             translation: "У меня аллергия на орехи.",          category: "Food", level: "A2"),
        Phrase(id: "f4",  english: "Is there a vegetarian option?",     translation: "Есть ли вегетарианский вариант?",    category: "Food", level: "A2"),
        Phrase(id: "f5",  english: "This is absolutely delicious!",     translation: "Это просто восхитительно!",          category: "Food", level: "A1"),
        Phrase(id: "f6",  english: "I'll have the same, please.",       translation: "То же самое, пожалуйста.",           category: "Food", level: "A1")
    ]
    static let politeness: [Phrase] = [
        Phrase(id: "p1",  english: "I beg your pardon?",                translation: "Прошу прощения?",                    category: "Politeness", level: "A2"),
        Phrase(id: "p2",  english: "After you.",                        translation: "После вас.",                         category: "Politeness", level: "A1"),
        Phrase(id: "p3",  english: "I'm terribly sorry about that.",    translation: "Мне ужасно жаль.",                   category: "Politeness", level: "B1"),
        Phrase(id: "p4",  english: "That's very kind of you.",          translation: "Это очень мило с вашей стороны.",    category: "Politeness", level: "A2"),
        Phrase(id: "p5",  english: "Don't mention it.",                 translation: "Не за что.",                         category: "Politeness", level: "A1"),
        Phrase(id: "p6",  english: "Would it be too much trouble if…?", translation: "Не будет ли слишком сложно, если…?", category: "Politeness", level: "B2")
    ]
    static let questions: [Phrase] = [
        Phrase(id: "q1",  english: "What exactly do you mean?",         translation: "Что именно вы имеете в виду?",       category: "Questions", level: "A2"),
        Phrase(id: "q2",  english: "How long does it take?",            translation: "Сколько это занимает времени?",      category: "Questions", level: "A1"),
        Phrase(id: "q3",  english: "Could you say that again, please?", translation: "Не могли бы вы повторить?",          category: "Questions", level: "A1"),
        Phrase(id: "q4",  english: "Is there anything else I should know?", translation: "Есть ли что-то ещё, что мне следует знать?", category: "Questions", level: "B1"),
        Phrase(id: "q5",  english: "What's the catch?",                 translation: "В чём подвох?",                      category: "Questions", level: "B2")
    ]
    static let emergency: [Phrase] = [
        Phrase(id: "em1", english: "Call an ambulance, please!",        translation: "Вызовите скорую, пожалуйста!",       category: "Emergency", level: "A1"),
        Phrase(id: "em2", english: "I've lost my passport.",            translation: "Я потерял паспорт.",                 category: "Emergency", level: "A2"),
        Phrase(id: "em3", english: "Is there a doctor nearby?",         translation: "Есть ли врач поблизости?",           category: "Emergency", level: "A2"),
        Phrase(id: "em4", english: "My bag has been stolen.",           translation: "Мою сумку украли.",                  category: "Emergency", level: "A2"),
        Phrase(id: "em5", english: "I need to contact my embassy.",     translation: "Мне нужно связаться с посольством.", category: "Emergency", level: "B1")
    ]
}
