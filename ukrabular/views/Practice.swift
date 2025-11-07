//
//  Practice.swift
//  ukrabular
//
//  Created by Maximilian Bieleke on 07.11.25.
//

import SwiftUI

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


struct PracticeView_Previews: PreviewProvider {
    static var previews: some View {
        PracticeView()
            .environmentObject(WordStore())
    }
}
