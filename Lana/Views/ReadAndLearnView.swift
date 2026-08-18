import SwiftUI

// MARK: - Read & Learn Hub

struct ReadAndLearnView: View {
    @EnvironmentObject private var appState: AppState
    @State private var selectedLevel = "All"

    private let levels = ["All", "A1", "A2", "B1", "B2", "C1"]

    private var filtered: [ReadArticle] {
        selectedLevel == "All"
            ? ReadArticle.all
            : ReadArticle.all.filter { $0.level == selectedLevel }
    }

    var body: some View {
        DarkScreen {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    header
                    levelPills
                    articleList
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 110)
            }
        }
    }

    // MARK: Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Read & Learn")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(LotusApp.ink)
            Text("Texts with vocabulary lookup")
                .font(.system(size: 14))
                .foregroundStyle(DarkDS.muted)
        }
        .padding(.top, 16)
    }

    // MARK: Level Filter Pills

    private var levelPills: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(levels, id: \.self) { lvl in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                            selectedLevel = lvl
                        }
                    } label: {
                        Text(lvl)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(selectedLevel == lvl ? .white : LotusApp.muted)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(
                                Capsule().fill(selectedLevel == lvl ? DarkDS.lime : DarkDS.card2)
                            )
                            .overlay(
                                Capsule().strokeBorder(
                                    selectedLevel == lvl ? Color.clear : DarkDS.border,
                                    lineWidth: 1
                                )
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 2)
        }
    }

    // MARK: Article List

    private var articleList: some View {
        VStack(spacing: 16) {
            ForEach(filtered) { article in
                NavigationLink {
                    ArticleDetailView(article: article)
                        .environmentObject(appState)
                } label: {
                    articleCard(article)
                }
                .buttonStyle(PressScaleStyle())
            }
        }
    }

    private func articleCard(_ article: ReadArticle) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(article.accentColor.opacity(0.18))
                        .frame(width: 46, height: 46)
                    Image(systemName: article.icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(article.accentColor)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text(article.category)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(article.accentColor)
                    Text(article.title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(LotusApp.ink)
                        .multilineTextAlignment(.leading)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(DarkDS.muted)
            }

            Text(article.preview)
                .font(.system(size: 13))
                .foregroundStyle(DarkDS.muted)
                .lineLimit(2)

            HStack(spacing: 14) {
                Label(article.level, systemImage: "chart.bar.fill")
                Label(article.readTime, systemImage: "clock")
                Label("+\(article.xp) XP", systemImage: "bolt.fill")
            }
            .font(.system(size: 11, weight: .medium))
            .foregroundStyle(DarkDS.muted)
        }
        .padding(18)
        .background(RoundedRectangle(cornerRadius: DarkDS.r).fill(DarkDS.card))
    }
}

// MARK: - Article Detail

struct ArticleDetailView: View {
    @EnvironmentObject private var appState: AppState
    let article: ReadArticle

    @State private var tappedWord: String?
    @State private var showDefinition = false
    @State private var xpAwarded = false

    var body: some View {
        DarkScreen {
            VStack(spacing: 0) {
                articleHeader
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        metaBadges
                        articleBody
                        if let word = tappedWord {
                            wordCard(word)
                        }
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 110)
                }
            }
        }
        .onAppear {
            if !xpAwarded {
                xpAwarded = true
                _ = appState.sqliteService.addXPOnce(key: "read_\(article.id)", amount: article.xp)
            }
        }
    }

    private var articleHeader: some View {
        HStack {
            DarkBackButton()
            Text(article.title)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(LotusApp.ink)
                .lineLimit(1)
            Spacer()
            Text("+\(article.xp) XP")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, 10).padding(.vertical, 5)
                .background(Capsule().fill(DarkDS.lime))
        }
        .padding(.horizontal, 20).padding(.vertical, 14)
        .background(DarkDS.card.opacity(0.8))
        .overlay(Rectangle().fill(DarkDS.border).frame(height: 1), alignment: .bottom)
    }

    private var metaBadges: some View {
        HStack(spacing: 10) {
            Label(article.level, systemImage: "chart.bar.fill")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(article.accentColor)
                .padding(.horizontal, 10).padding(.vertical, 5)
                .background(Capsule().fill(article.accentColor.opacity(0.15)))
            Label(article.readTime, systemImage: "clock")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(DarkDS.muted)
                .padding(.horizontal, 10).padding(.vertical, 5)
                .background(Capsule().fill(DarkDS.card2))
            Spacer()
            Text("Tap words to look up")
                .font(.system(size: 11))
                .foregroundStyle(DarkDS.muted)
        }
    }

    private var articleBody: some View {
        VStack(alignment: .leading, spacing: 14) {
            ForEach(article.paragraphs, id: \.self) { para in
                tappableText(para)
            }
        }
        .padding(18)
        .background(RoundedRectangle(cornerRadius: DarkDS.r).fill(DarkDS.card))
    }

    private func tappableText(_ text: String) -> some View {
        let words = text.components(separatedBy: " ")
        return FlowLayout(spacing: 4) {
            ForEach(Array(words.enumerated()), id: \.offset) { _, word in
                let clean = word.trimmingCharacters(in: .punctuationCharacters).lowercased()
                Button {
                    tappedWord = clean
                } label: {
                    Text(word + " ")
                        .font(.system(size: 15))
                        .foregroundStyle(tappedWord == clean ? DarkDS.lime : .white.opacity(0.88))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func wordCard(_ word: String) -> some View {
        let def = WordDefinitions.lookup(word)
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(word.capitalized)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(LotusApp.ink)
                    if let pos = def?.partOfSpeech {
                        Text(pos)
                            .font(.system(size: 12))
                            .foregroundStyle(DarkDS.lime)
                    }
                }
                Spacer()
                Button {
                    tappedWord = nil
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(DarkDS.muted)
                }
            }
            Divider().background(DarkDS.border)
            Text(def?.definition ?? "A commonly used English word.")
                .font(.system(size: 14))
                .foregroundStyle(LotusApp.ink.opacity(0.85))
            if let example = def?.example {
                Text("\"" + example + "\"")
                    .font(.system(size: 13))
                    .italic()
                    .foregroundStyle(DarkDS.muted)
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: DarkDS.r).fill(DarkDS.card2))
        .overlay(RoundedRectangle(cornerRadius: DarkDS.r).strokeBorder(DarkDS.lime.opacity(0.4), lineWidth: 1))
    }
}

// MARK: - Word Definitions

struct WordDefinition {
    let partOfSpeech: String
    let definition: String
    let example: String?
}

enum WordDefinitions {
    static func lookup(_ word: String) -> WordDefinition? {
        dict[word.lowercased()]
    }

    static let dict: [String: WordDefinition] = [
        "fluent":      WordDefinition(partOfSpeech: "adjective", definition: "Able to speak or write a language very well and accurately.", example: "She is fluent in three languages."),
        "vocabulary":  WordDefinition(partOfSpeech: "noun", definition: "The set of words known and used by a person.", example: "Reading helps expand your vocabulary."),
        "grammar":     WordDefinition(partOfSpeech: "noun", definition: "The set of structural rules governing the composition of sentences.", example: "Good grammar makes your writing clearer."),
        "practice":    WordDefinition(partOfSpeech: "noun/verb", definition: "Repeated exercise to improve skill.", example: "Daily practice is key to fluency."),
        "communicate": WordDefinition(partOfSpeech: "verb", definition: "To share or exchange information or feelings.", example: "Learning English helps you communicate globally."),
        "culture":     WordDefinition(partOfSpeech: "noun", definition: "The ideas, customs, and social behaviour of a society.", example: "Travel exposes you to different cultures."),
        "confident":   WordDefinition(partOfSpeech: "adjective", definition: "Feeling certain about your abilities.", example: "She felt confident speaking in public."),
        "essential":   WordDefinition(partOfSpeech: "adjective", definition: "Absolutely necessary; extremely important.", example: "Water is essential for life."),
        "context":     WordDefinition(partOfSpeech: "noun", definition: "The circumstances surrounding a word or event that clarify its meaning.", example: "Understanding context helps with vocabulary."),
        "improve":     WordDefinition(partOfSpeech: "verb", definition: "To make or become better.", example: "Reading daily will improve your English."),
        "immersion":   WordDefinition(partOfSpeech: "noun", definition: "The practice of surrounding yourself fully with a language.", example: "Language immersion is the fastest way to learn."),
        "accent":      WordDefinition(partOfSpeech: "noun", definition: "A distinctive way of pronouncing a language.", example: "He has a British accent."),
        "native":      WordDefinition(partOfSpeech: "adjective", definition: "Relating to the place or language of one's birth.", example: "Her native language is Spanish."),
        "acquire":     WordDefinition(partOfSpeech: "verb", definition: "To learn or develop a skill over time.", example: "Children acquire language naturally."),
        "exposure":    WordDefinition(partOfSpeech: "noun", definition: "The experience of encountering something.", example: "Regular exposure to English speeds up learning."),
        "persistence": WordDefinition(partOfSpeech: "noun", definition: "Continuing firmly despite difficulty.", example: "Persistence is the key to mastering any skill."),
        "global":      WordDefinition(partOfSpeech: "adjective", definition: "Relating to the whole world.", example: "English is the global language of business."),
        "technology":  WordDefinition(partOfSpeech: "noun", definition: "The application of scientific knowledge for practical purposes.", example: "Technology has changed the way we learn languages."),
        "achievement": WordDefinition(partOfSpeech: "noun", definition: "A thing done successfully with effort.", example: "Learning a new language is a great achievement."),
        "challenge":   WordDefinition(partOfSpeech: "noun", definition: "A task or situation that requires great effort.", example: "Speaking in public is a common challenge."),
    ]
}

// MARK: - Data Models

struct ReadArticle: Identifiable {
    let id: String
    let title: String
    let category: String
    let level: String
    let readTime: String
    let xp: Int
    let icon: String
    let accentColor: Color
    let preview: String
    let paragraphs: [String]

    static let all: [ReadArticle] = [
        ReadArticle(
            id: "secret_fluency",
            title: "The Secret to Fluent English",
            category: "Language Tips",
            level: "B1",
            readTime: "5 min",
            xp: 20,
            icon: "lightbulb.fill",
            accentColor: DarkDS.lime,
            preview: "Many learners ask: what is the secret to speaking English fluently? The answer might surprise you.",
            paragraphs: [
                "Many learners ask: what is the secret to speaking English fluently? The answer might surprise you — it is not about memorising more grammar rules.",
                "Fluency comes from confidence and practice. When you speak without fear of making mistakes, your brain begins to process language automatically. This is called fluent communication.",
                "The most successful learners immerse themselves in the language every day. They listen to podcasts, watch films, and most importantly — they speak. Every conversation, even a short one, counts.",
                "Vocabulary is also essential. Try to learn new words in context, not in isolated lists. When you see a word used in a real sentence, you are far more likely to remember it.",
                "Finally, be patient with yourself. Acquiring a language takes time and persistence. Celebrate every small achievement and keep your motivation high. You are already doing great."
            ]
        ),
        ReadArticle(
            id: "daily_habits",
            title: "5 Daily Habits of Great English Speakers",
            category: "Study Tips",
            level: "A2",
            readTime: "4 min",
            xp: 15,
            icon: "sun.max.fill",
            accentColor: Color(red: 0.98, green: 0.60, blue: 0.18),
            preview: "Top English speakers all share certain habits. Build these into your routine and you will notice rapid improvement.",
            paragraphs: [
                "Top English speakers all share certain habits. Build these five into your daily routine and you will see rapid improvement.",
                "First, read something in English every morning — even a short news headline. This warms up your brain and exposes you to natural language structures.",
                "Second, speak out loud to yourself. Describe what you are doing, think in English, or practise phrases you have just learned. This builds muscle memory.",
                "Third, keep a vocabulary notebook. Write down new words with their meaning and an example sentence. Review it every evening.",
                "Fourth, watch one short English video per day. Films, series, and YouTube are all excellent resources. Turn on subtitles in English, not your native language.",
                "Fifth — and most importantly — do not give up. Consistency is more powerful than intensity. Fifteen minutes every day beats three hours once a week."
            ]
        ),
        ReadArticle(
            id: "english_global",
            title: "Why English Became the Global Language",
            category: "Culture",
            level: "B2",
            readTime: "6 min",
            xp: 25,
            icon: "globe.europe.africa.fill",
            accentColor: Color(red: 0.22, green: 0.44, blue: 0.98),
            preview: "English is spoken by over 1.5 billion people worldwide. But how did one language come to dominate global communication?",
            paragraphs: [
                "English is spoken by over 1.5 billion people worldwide, making it the most widely used language for global communication. But how did this happen?",
                "The roots of English's global spread lie in the British Empire of the 17th to 19th centuries. As Britain expanded its territories across Asia, Africa, and the Americas, the English language travelled with it.",
                "Then, in the 20th century, the United States emerged as an economic and cultural superpower. Hollywood films, American music, and Silicon Valley technology carried English to every corner of the world.",
                "Today, English is the dominant language of science, diplomacy, aviation, and the internet. It is used as a shared language — or lingua franca — between speakers of completely different native tongues.",
                "Learning English is therefore not just a personal achievement. It is a global key that opens doors to education, careers, travel, and culture. You are learning the language of the world."
            ]
        ),
        ReadArticle(
            id: "grammar_mistakes",
            title: "The 7 Most Common Grammar Mistakes",
            category: "Grammar",
            level: "A2",
            readTime: "4 min",
            xp: 15,
            icon: "pencil.and.outline",
            accentColor: Color(red: 0.62, green: 0.38, blue: 0.98),
            preview: "Even advanced learners make these grammar mistakes. Read on to learn how to avoid them.",
            paragraphs: [
                "Even advanced English learners make the same grammar mistakes. Knowing these common errors will help you communicate more accurately.",
                "Number one: confusing 'its' and 'it's'. 'It's' is a contraction of 'it is', while 'its' shows possession. Example: 'It's a great book. Its cover is beautiful.'",
                "Number two: using 'much' with countable nouns. You should say 'many books', not 'much books'. Use 'much' only with uncountable nouns like water or time.",
                "Number three: forgetting the third-person 's'. In the present simple, we add 's' for he, she, and it. 'She work hard' is wrong — the correct form is 'She works hard.'",
                "Number four: mixing up 'since' and 'for'. Use 'since' with a point in time — 'since Monday' — and 'for' with a duration — 'for three days'.",
                "The key to avoiding these mistakes is not to fear them. Make them, learn from them, and keep going. Every mistake is a step forward."
            ]
        ),
        ReadArticle(
            id: "travel_english",
            title: "Essential English for Travelling Abroad",
            category: "Travel",
            level: "A1",
            readTime: "3 min",
            xp: 10,
            icon: "airplane",
            accentColor: Color(red: 0.20, green: 0.78, blue: 0.43),
            preview: "Planning a trip? These phrases will help you navigate airports, hotels, and restaurants with confidence.",
            paragraphs: [
                "Travelling to an English-speaking country — or any country where English is used — can feel daunting. But a small set of essential phrases will take you a long way.",
                "At the airport: 'Where is the check-in desk?' / 'Could you help me with my luggage?' / 'Is this the gate for the flight to London?'",
                "At the hotel: 'I have a reservation under the name...' / 'Could I have a room with a view?' / 'What time is breakfast?'",
                "At a restaurant: 'Could I see the menu, please?' / 'I'd like to order...' / 'Could I have the bill, please?'",
                "When you are lost: 'Excuse me, could you tell me how to get to...?' / 'Is it far from here?' / 'Could you write that down for me?'",
                "Remember: most people appreciate when you try to communicate in their language. Even a few words with a smile goes a very long way."
            ]
        ),
        ReadArticle(
            id: "body_language",
            title: "Body Language in English-Speaking Cultures",
            category: "Culture",
            level: "B1",
            readTime: "5 min",
            xp: 20,
            icon: "person.fill",
            accentColor: Color(red: 0.98, green: 0.79, blue: 0.20),
            preview: "Communication is more than words. Understanding body language will help you connect more naturally with native speakers.",
            paragraphs: [
                "When learning English, most people focus entirely on words. But communication is far more than language — up to 70% of meaning is conveyed through body language.",
                "Eye contact is very important in most English-speaking cultures. Maintaining moderate eye contact during a conversation signals that you are engaged and respectful. Avoiding it may be interpreted as nervousness or dishonesty.",
                "Personal space also matters. In the UK and USA, people generally prefer to stand about an arm's length apart during conversations. Standing too close may make the other person uncomfortable.",
                "Handshakes are the standard professional greeting in most English-speaking countries. A firm — but not crushing — handshake signals confidence.",
                "Smiling is a universal signal of warmth and openness. In informal situations, a smile while saying 'hello' goes a long way toward making a good first impression.",
                "By being aware of these cultural signals, you will communicate more naturally and feel more confident in real-life interactions."
            ]
        ),
        ReadArticle(
            id: "tech_vocabulary",
            title: "Tech Vocabulary: Words You Need to Know",
            category: "Technology",
            level: "B2",
            readTime: "5 min",
            xp: 25,
            icon: "cpu.fill",
            accentColor: Color(red: 0.62, green: 0.38, blue: 0.98),
            preview: "The tech world is full of English jargon. Master these key terms and keep up with the digital conversation.",
            paragraphs: [
                "Technology has given the English language hundreds of new words. Many of these are used globally, so understanding them is essential for modern communication.",
                "'Algorithm': a set of rules or instructions that a computer follows to solve a problem. 'The social media algorithm decides what you see in your feed.'",
                "'Bandwidth': the amount of data that can be transferred over a connection in a given time. 'Our internet bandwidth is too slow for video calls.'",
                "'Cloud': remote servers accessed via the internet. 'I store all my photos in the cloud so I never lose them.'",
                "'Disruptive': describes technology that fundamentally changes an industry. 'The smartphone was a disruptive technology.'",
                "'Encryption': the process of converting data into a code to prevent unauthorised access. 'Your messages are protected by end-to-end encryption.'",
                "Learning technology vocabulary will help you in job interviews, meetings, and everyday conversation in the digital age."
            ]
        ),
        ReadArticle(
            id: "small_talk",
            title: "The Art of Small Talk in English",
            category: "Speaking",
            level: "A2",
            readTime: "4 min",
            xp: 15,
            icon: "person.2.fill",
            accentColor: Color(red: 0.22, green: 0.44, blue: 0.98),
            preview: "Small talk can feel awkward — but it is a vital social skill. Learn how to start and keep a conversation going.",
            paragraphs: [
                "Small talk — light, casual conversation — is a vital social skill in English-speaking cultures. Many learners find it more challenging than formal language, but with a few strategies, it becomes natural.",
                "The most common topic for small talk in Britain is the weather. It sounds cliché, but a simple comment like 'Lovely day, isn't it?' is an excellent conversation opener.",
                "Ask open questions to keep the conversation going. Instead of 'Did you have a good weekend?', try 'What did you get up to this weekend?' — this invites a longer, more interesting answer.",
                "Listen actively. Show you are interested with short responses like 'Really?', 'Oh, how interesting!', or 'I know exactly what you mean!'",
                "Be positive and friendly. Small talk is not about exchanging deep opinions — it is about making people feel comfortable. Keep it light, smile, and enjoy the moment.",
                "Remember: the goal of small talk is connection, not information. Practice it every day and you will feel completely natural in no time."
            ]
        ),
        ReadArticle(
            id: "idioms",
            title: "10 Must-Know English Idioms",
            category: "Vocabulary",
            level: "B1",
            readTime: "5 min",
            xp: 20,
            icon: "text.quote",
            accentColor: Color(red: 0.98, green: 0.30, blue: 0.30),
            preview: "Idioms are phrases whose meaning is different from the literal words. Native speakers use them all the time.",
            paragraphs: [
                "Idioms are phrases where the meaning is different from the individual words. Native speakers use them constantly — so understanding them is key to natural communication.",
                "'Break a leg' — good luck. Used before a performance or important event. 'Break a leg at your presentation today!'",
                "'Hit the nail on the head' — to be exactly right. 'You hit the nail on the head — that's exactly the problem.'",
                "'Under the weather' — feeling unwell. 'I'm a bit under the weather today, I might skip the gym.'",
                "'Bite the bullet' — to endure a painful or difficult situation. 'I'll just have to bite the bullet and do the exam.'",
                "'Piece of cake' — something very easy. 'The test was a piece of cake — I finished in ten minutes.'",
                "'Cost an arm and a leg' — to be very expensive. 'That handbag costs an arm and a leg!'",
                "Learning idioms in context is the best approach. Try to use one new idiom each day and it will soon become part of your natural vocabulary."
            ]
        ),
        ReadArticle(
            id: "job_interview",
            title: "How to Ace a Job Interview in English",
            category: "Business",
            level: "B2",
            readTime: "6 min",
            xp: 25,
            icon: "briefcase.fill",
            accentColor: DarkDS.lime,
            preview: "A job interview in English can be nerve-wracking. But with the right preparation, you can impress any employer.",
            paragraphs: [
                "Interviewing for a job in English can feel nerve-wracking. But with good preparation, you can walk into any interview with confidence.",
                "Research the company. Before the interview, read the company's website and understand what they do. This allows you to tailor your answers and show genuine interest.",
                "Prepare for common questions. 'Tell me about yourself', 'What are your strengths and weaknesses?', and 'Where do you see yourself in five years?' are almost universal. Practise your answers out loud.",
                "Use the STAR method for behavioural questions. STAR stands for Situation, Task, Action, and Result. When asked 'Tell me about a challenge you overcame', describe the situation, your task, the action you took, and the result you achieved.",
                "Pay attention to your language. Avoid very informal phrases. Use professional vocabulary like 'I am highly motivated', 'I have extensive experience in', or 'I am confident that I can contribute to your team.'",
                "Finally, prepare one or two thoughtful questions for the interviewer. Asking 'What does success look like in this role?' shows initiative and genuine interest. Good luck — you've got this!"
            ]
        )
    ]
}
