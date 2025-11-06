import SwiftUI
import Combine

// MARK: - Model
struct WordPair: Identifiable, Codable, Equatable {
    let id: UUID
    var german: String
    var ukrainian: String

    init(id: UUID = UUID(), german: String, ukrainian: String) {
        self.id = id
        self.german = german
        self.ukrainian = ukrainian
    }
}

// MARK: - Persistence / Store
final class WordStore: ObservableObject {
    @Published var words: [WordPair] = [] {
        didSet { save() }
    }

    private let filename = "wordpairs.json"
    private var fileURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(filename)
    }

    init() {
        self.load()
        if words.isEmpty {
            words = [
                WordPair(german: "Hallo", ukrainian: "Привіт"),
                WordPair(german: "Danke", ukrainian: "Дякую"),
                WordPair(german: "Bitte", ukrainian: "Будь ласка")
            ]
        }
    }

    func add(german: String, ukrainian: String) {
        let trimmedG = german.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedU = ukrainian.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedG.isEmpty && !trimmedU.isEmpty else { return }
        words.append(WordPair(german: trimmedG, ukrainian: trimmedU))
    }

    func remove(at offsets: IndexSet) {
        words.remove(atOffsets: offsets)
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(words)
            try data.write(to: fileURL, options: [.atomicWrite])
        } catch {
            print("Save error: \(error)")
        }
    }

    private func load() {
        do {
            let data = try Data(contentsOf: fileURL)
            words = try JSONDecoder().decode([WordPair].self, from: data)
        } catch {
            // ignore - file might not exist yet
            print("Load error (if new app this is expected): \(error)")
        }
    }
}

// MARK: - Views
struct ContentView: View {
    var body: some View {
        TabView {
            WordListView()
                .tabItem {
                    Label("Words", systemImage: "list.bullet")
                }

            PracticeView()
                .tabItem {
                    Label("Practice", systemImage: "brain.head.profile")
                }
        }
    }
}

// Word list + add
struct WordListView: View {
    @EnvironmentObject private var store: WordStore
    @State private var showingAdd = false

    var body: some View {
        NavigationView {
            List {
                ForEach(store.words) { word in
                    VStack(alignment: .leading) {
                        Text(word.german)
                            .font(.headline)
                        Text(word.ukrainian)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                .onDelete(perform: store.remove)
            }
            .navigationTitle("Word Pairs")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAdd = true }) {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Add word pair")
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddWordView(isPresented: $showingAdd)
                    .environmentObject(store)
            }
        }
    }
}

struct AddWordView: View {
    @EnvironmentObject private var store: WordStore
    @Binding var isPresented: Bool

    @State private var german = ""
    @State private var ukrainian = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("German")) {
                    TextField("z. B. Haus", text: $german)
                        .autocapitalization(.words)
                }
                Section(header: Text("Ukrainian")) {
                    TextField("Наприклад: дім", text: $ukrainian)
                        .autocapitalization(.words)
                }
            }
            .navigationTitle("Add word pair")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        store.add(german: german, ukrainian: ukrainian)
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { isPresented = false }
                }
            }
        }
    }
}

// Practice view / quiz
struct PracticeView: View {
    @EnvironmentObject private var store: WordStore

    @State private var direction: PracticeDirection = .ukToDe
    @State private var currentIndex = 0
    @State private var practiceWords: [WordPair] = []
    @State private var userAnswer = ""
    @State private var feedback: String? = nil
    @State private var showAnswer = false
    @State private var correctCount = 0
    @State private var askedCount = 0

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if practiceWords.isEmpty {
                    Text("No words yet — add some in the Words tab")
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    HStack {
                        Text("Direction:")
                        Picker("Direction", selection: $direction) {
                            Text("Ukr → Ger").tag(PracticeDirection.ukToDe)
                            Text("Ger → Ukr").tag(PracticeDirection.deToUk)
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding(.horizontal)

                    Spacer()

                    // Prompt
                    VStack(spacing: 8) {
                        Text(promptText())
                            .font(.largeTitle)
                            .multilineTextAlignment(.center)

                        if showAnswer {
                            Text(answerText())
                                .font(.title3)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()

                    // Answer input
                    VStack(spacing: 8) {
                        TextField("Your translation", text: $userAnswer)
                            .textFieldStyle(.roundedBorder)
                            .padding(.horizontal)

                        HStack {
                            Button("Check") { checkAnswer() }
                                .buttonStyle(.borderedProminent)

                            Button(showAnswer ? "Hide" : "Show answer") {
                                showAnswer.toggle()
                            }
                            .buttonStyle(.bordered)

                            Button("Next") { nextCard() }
                                .buttonStyle(.bordered)
                        }
                    }

                    // Feedback & score
                    if let fb = feedback {
                        Text(fb)
                            .font(.headline)
                            .foregroundColor(fb.starts(with: "Correct") ? .green : .red)
                            .padding(.top)
                    }

                    Spacer()

                    Text("Score: \(correctCount) / \(askedCount)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.bottom)
                }
            }
            .navigationTitle("Practice")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Shuffle & Start") { startPractice() }
                }
            }
            .onAppear { startPractice() }
        }
    }

    private func startPractice() {
        practiceWords = store.words.shuffled()
        currentIndex = 0
        userAnswer = ""
        feedback = nil
        showAnswer = false
        correctCount = 0
        askedCount = 0
    }

    private func promptText() -> String {
        guard !practiceWords.isEmpty else { return "—" }
        let pair = practiceWords[currentIndex]
        return direction == .ukToDe ? pair.ukrainian : pair.german
    }

    private func answerText() -> String {
        guard !practiceWords.isEmpty else { return "" }
        let pair = practiceWords[currentIndex]
        return direction == .ukToDe ? pair.german : pair.ukrainian
    }

    private func checkAnswer() {
        guard !practiceWords.isEmpty else { return }
        let correct = answerText().trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let given = userAnswer.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        askedCount += 1
        if normalize(given) == normalize(correct) {
            feedback = "Correct ✅ — \(answerText())"
            correctCount += 1
        } else {
            feedback = "Incorrect ❌ — correct: \(answerText())"
        }
        // keep the answer visible after checking
        showAnswer = true
    }

    private func nextCard() {
        guard !practiceWords.isEmpty else { return }
        userAnswer = ""
        feedback = nil
        showAnswer = false
        currentIndex = (currentIndex + 1) % practiceWords.count
    }

    private func normalize(_ s: String) -> String {
        // simple normalization: lowercased + remove diacritics and extra spaces
        let trimmed = s.trimmingCharacters(in: .whitespacesAndNewlines)
        let folded = trimmed.folding(options: [.diacriticInsensitive, .widthInsensitive, .caseInsensitive], locale: .current)
        return folded
    }
}

enum PracticeDirection {
    case ukToDe
    case deToUk
}

// MARK: - Previews
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(WordStore())
    }
}
