import Foundation
import AVFoundation
import Combine

final class PronunciationPracticeViewModel: NSObject, ObservableObject, AVAudioRecorderDelegate {
    @Published var currentWord: SavedWord?
    @Published var isPlaying = false
    @Published var isRecording = false
    @Published var hasRecording = false
    @Published var selfRating: Int? = nil  // 1=Hard, 3=OK, 5=Great
    @Published var wordIndex: Int = 0

    private let sqliteService: SQLiteService
    private var words: [SavedWord] = []
    private var synthesizer = AVSpeechSynthesizer()
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var recordingURL: URL {
        FileManager.default.temporaryDirectory.appendingPathComponent("pronunciation_rec.m4a")
    }

    init(sqliteService: SQLiteService) {
        self.sqliteService = sqliteService
        super.init()
        words = sqliteService.fetchSavedWords()
        currentWord = words.first
    }

    func speakWord() {
        guard let word = currentWord else { return }
        let utterance = AVSpeechUtterance(string: word.word)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.45
        isPlaying = true
        synthesizer.speak(utterance)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in self?.isPlaying = false }
    }

    func startRecording() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playAndRecord, mode: .default)
        try? session.setActive(true)
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        audioRecorder = try? AVAudioRecorder(url: recordingURL, settings: settings)
        audioRecorder?.delegate = self
        audioRecorder?.record()
        isRecording = true
    }

    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
        hasRecording = true
        try? AVAudioSession.sharedInstance().setCategory(.playback)
    }

    func playRecording() {
        guard hasRecording else { return }
        audioPlayer = try? AVAudioPlayer(contentsOf: recordingURL)
        audioPlayer?.play()
    }

    func submitRating(_ rating: Int) {
        selfRating = rating
        sqliteService.recordSRSReview(wordId: currentWord?.id ?? "", quality: rating)
        if rating >= 3 { sqliteService.addXPOnce(key: "pronunciation_\(currentWord?.id ?? "")", amount: 10) }
    }

    func nextWord() {
        wordIndex = (wordIndex + 1) % max(1, words.count)
        currentWord = words.isEmpty ? nil : words[wordIndex]
        hasRecording = false
        selfRating = nil
        isPlaying = false
        isRecording = false
    }
}
