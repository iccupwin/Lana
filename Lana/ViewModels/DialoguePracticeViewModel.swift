import Foundation
import Combine
import UIKit

// MARK: - Models

enum DialogueSpeaker { case native, user }

struct DialogueTurn: Identifiable {
    let id = UUID()
    let speaker: DialogueSpeaker
    let text: String          // correct / native text
    let wrongOptions: [String] // 2 wrong options (empty for native turns)

    static func native(_ text: String) -> DialogueTurn {
        DialogueTurn(speaker: .native, text: text, wrongOptions: [])
    }
    static func user(_ correct: String, wrong1: String, wrong2: String) -> DialogueTurn {
        DialogueTurn(speaker: .user, text: correct, wrongOptions: [wrong1, wrong2])
    }
}

struct DialogueScenario: Identifiable {
    let id: String
    let title: String
    let icon: String
    let situation: String
    let turns: [DialogueTurn]
}

// MARK: - ViewModel

final class DialoguePracticeViewModel: ObservableObject {
    @Published var visibleTurns: [RenderedTurn] = []
    @Published var currentIndex: Int = 0
    @Published var isChoosingOption: Bool = false
    @Published var isAnswered: Bool = false
    @Published var lastAnswerCorrect: Bool = false
    @Published var score: Int = 0
    @Published var isFinished: Bool = false

    struct RenderedTurn: Identifiable {
        let id = UUID()
        let speaker: DialogueSpeaker
        let text: String
        let isUserChoice: Bool   // was this the user's actual pick
        let wasCorrect: Bool?    // nil for native turns
    }

    struct OptionSet: Identifiable {
        let id = UUID()
        let options: [String]
        let correctOption: String
    }

    let scenario: DialogueScenario
    private(set) var optionSets: [UUID: OptionSet] = [:]  // turnId → shuffled options
    private var pendingUserTurnId: UUID? = nil

    init(scenario: DialogueScenario) {
        self.scenario = scenario
        precomputeOptions()
        advance()
    }

    var totalUserTurns: Int { scenario.turns.filter { $0.speaker == .user }.count }

    // MARK: - Actions

    func chooseOption(_ option: String) {
        guard isChoosingOption, !isAnswered else { return }
        guard let turnId = pendingUserTurnId,
              let optSet = optionSets[turnId] else { return }

        isAnswered = true
        lastAnswerCorrect = (option == optSet.correctOption)
        if lastAnswerCorrect {
            score += 1
            HapticService.shared.notify(.success)
        } else {
            HeartsService.shared.useHeart()
            HapticService.shared.notify(.error)
        }

        visibleTurns.append(RenderedTurn(
            speaker: .user,
            text: option,
            isUserChoice: true,
            wasCorrect: lastAnswerCorrect
        ))
    }

    func continueDialogue() {
        HapticService.shared.impact(.light)
        isAnswered = false
        isChoosingOption = false
        pendingUserTurnId = nil
        currentIndex += 1
        advance()
    }

    // MARK: - Internal

    private func advance() {
        guard currentIndex < scenario.turns.count else {
            isFinished = true
            SQLiteService.shared.addXP(score * 5)
            return
        }

        let turn = scenario.turns[currentIndex]
        if turn.speaker == .native {
            visibleTurns.append(RenderedTurn(
                speaker: .native,
                text: turn.text,
                isUserChoice: false,
                wasCorrect: nil
            ))
        } else {
            pendingUserTurnId = turn.id
            isChoosingOption = true
        }
    }

    private func precomputeOptions() {
        for turn in scenario.turns where turn.speaker == .user {
            let shuffled = ([turn.text] + turn.wrongOptions).shuffled()
            optionSets[turn.id] = OptionSet(options: shuffled, correctOption: turn.text)
        }
    }

    var currentOptionSet: OptionSet? {
        guard let id = pendingUserTurnId else { return nil }
        return optionSets[id]
    }

    // MARK: - All Scenarios

    static let allScenarios: [DialogueScenario] = [
        DialogueScenario(
            id: "cafe",
            title: "At the Café",
            icon: "cup.and.saucer.fill",
            situation: "You're ordering coffee at a local café.",
            turns: [
                .native("Hi there! What can I get for you today?"),
                .user("Good morning! I'd like a large latte, please.",
                      wrong1: "Large latte, give me.",
                      wrong2: "I want latte big, please."),
                .native("Sure! Would you like that hot or iced?"),
                .user("Hot, please. Could I also get oat milk?",
                      wrong1: "Yes hot. Oat milk also.",
                      wrong2: "Hot. And milk from oats."),
                .native("Of course! Anything else?"),
                .user("No, that's all. How much is it?",
                      wrong1: "No more. Price how much?",
                      wrong2: "Nothing. Money?"),
                .native("That's $5.50. You can tap your card here."),
                .user("Here you go. Thank you so much!",
                      wrong1: "Ok. I give card.",
                      wrong2: "Take this. Bye."),
            ]
        ),
        DialogueScenario(
            id: "airport",
            title: "At the Airport",
            icon: "airplane",
            situation: "You're checking in for your flight.",
            turns: [
                .native("Good morning! Can I see your passport, please?"),
                .user("Of course. Here it is.",
                      wrong1: "Yes. Take it.",
                      wrong2: "Here passport."),
                .native("Thank you. How many bags are you checking in?"),
                .user("Just one suitcase. Is there a weight limit?",
                      wrong1: "One bag. Weight limit exists?",
                      wrong2: "Only suitcase one. Limit weight?"),
                .native("Yes, 23 kilograms. Would you like a window or aisle seat?"),
                .user("A window seat would be great, please.",
                      wrong1: "Window seat, yes please give.",
                      wrong2: "I want near window."),
                .native("Perfect. Your gate is B14. Boarding starts at 10:30."),
                .user("Thank you. Is there a lounge I can use?",
                      wrong1: "Ok. Lounge where is?",
                      wrong2: "Thanks. Can I lounge use?"),
            ]
        ),
        DialogueScenario(
            id: "hotel",
            title: "Hotel Check-in",
            icon: "building.2.fill",
            situation: "You've just arrived at your hotel.",
            turns: [
                .native("Welcome! Do you have a reservation?"),
                .user("Yes, I booked a room for two nights. The name is Johnson.",
                      wrong1: "Yes, reservation is there. Name Johnson.",
                      wrong2: "I booked. Johnson name mine."),
                .native("Let me check… Yes, a double room. Could I see an ID?"),
                .user("Sure, here's my passport.",
                      wrong1: "Yes. Passport take.",
                      wrong2: "Ok, see passport here."),
                .native("Great. Breakfast is served from 7 to 10 AM in the restaurant."),
                .user("That sounds lovely. Is there free Wi-Fi in the rooms?",
                      wrong1: "Good. Rooms have free wifi?",
                      wrong2: "Nice. Wi-Fi free exist rooms?"),
                .native("Yes, the password is on your key card envelope. Enjoy your stay!"),
                .user("Thank you very much. Could you recommend a good restaurant nearby?",
                      wrong1: "Thanks. Good restaurant near where?",
                      wrong2: "Ok thanks. Nearby restaurant good?"),
            ]
        ),
        DialogueScenario(
            id: "doctor",
            title: "At the Doctor",
            icon: "stethoscope",
            situation: "You're seeing a doctor for the first time.",
            turns: [
                .native("Good afternoon! What brings you in today?"),
                .user("I've had a headache and a sore throat for three days.",
                      wrong1: "Headache and throat sore, three days now.",
                      wrong2: "I have head pain and throat, since three days."),
                .native("I see. Do you have a fever or any other symptoms?"),
                .user("I had a slight fever yesterday, but it seems to have gone.",
                      wrong1: "Yesterday little fever, today gone it seems.",
                      wrong2: "Fever small yesterday. Now no fever seems."),
                .native("Let me take a look. Can you open your mouth wide?"),
                .user("Of course. Is it serious?",
                      wrong1: "Ok opening. Serious is it?",
                      wrong2: "Sure. It serious?"),
                .native("It looks like a mild infection. I'll prescribe some antibiotics."),
                .user("Should I avoid anything while taking them?",
                      wrong1: "Taking them, avoid what?",
                      wrong2: "While antibiotics, what avoid should I?"),
            ]
        ),
        DialogueScenario(
            id: "interview",
            title: "Job Interview",
            icon: "briefcase.fill",
            situation: "You're interviewing for a position at a company.",
            turns: [
                .native("Thanks for coming in. Tell me a bit about yourself."),
                .user("I have five years of experience in marketing and I'm passionate about data-driven campaigns.",
                      wrong1: "Five years marketing. I like data campaigns.",
                      wrong2: "Marketing five year experience. Data campaigns passion."),
                .native("Interesting. Why do you want to work for us specifically?"),
                .user("I admire your company's approach to innovation and I believe I can contribute significantly.",
                      wrong1: "Your company innovation I like. I contribute can.",
                      wrong2: "I admire innovation of company. Contribute I can."),
                .native("What would you say is your greatest strength?"),
                .user("I'm very detail-oriented and I work well under pressure.",
                      wrong1: "Details I see well and pressure work good.",
                      wrong2: "My strength is detail and pressure working."),
                .native("Do you have any questions for us?"),
                .user("Yes — what does the onboarding process look like?",
                      wrong1: "Yes. Onboarding how it is?",
                      wrong2: "Yes. How onboarding looks like?"),
            ]
        ),
        DialogueScenario(
            id: "shopping",
            title: "Shopping for Clothes",
            icon: "bag.fill",
            situation: "You're looking for a jacket at a clothing store.",
            turns: [
                .native("Hi! Can I help you find anything today?"),
                .user("Yes, please. I'm looking for a warm jacket for winter.",
                      wrong1: "Yes. Warm jacket for winter I want.",
                      wrong2: "Please yes. I look warm jacket winter."),
                .native("We have some great options. What size are you?"),
                .user("I'm usually a medium, but I'd like to try a large as well.",
                      wrong1: "Medium usually. Large also try want.",
                      wrong2: "I am medium. Large also I want try."),
                .native("Of course! This one is very popular. Would you like to try it on?"),
                .user("Absolutely. Where are the fitting rooms?",
                      wrong1: "Yes. Fitting rooms where are?",
                      wrong2: "Sure yes. Where fitting rooms?"),
                .native("Just around the corner on your left."),
                .user("Thank you. Do you have this in a different colour as well?",
                      wrong1: "Thanks. Other colour this exists?",
                      wrong2: "Ok thanks. This other colour has?"),
            ]
        ),
    ]
}
