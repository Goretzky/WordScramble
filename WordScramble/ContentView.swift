import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var score = 0  // Track player's score

    var body: some View {
        NavigationStack {
            VStack {
                // Score Display
                Text("Score: \(score)")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()

                List {
                    Section {
                        TextField("Enter your word", text: $newWord)
                            .textInputAutocapitalization(.never)
                    }
                    
                    Section {
                        ForEach(usedWords, id: \.self) { word in
                            HStack {
                                Image(systemName: "\(word.count).circle")
                                Text(word)
                            }
                        }
                    }
                }
            }
            .toolbar {
                Button("Start New Game", action: startGame)
            }
            .navigationTitle(rootWord)
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
        }
    }

    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > 2,
              isMadeFromRootWord(answer),
              !usedWords.contains(answer),
              !newWord.contains(rootWord),
              isRealWord(answer)
        else { return }
        
        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        
        // **Update Score**
        score += 1 + answer.count  // 1 point for the word + 1 per letter
        newWord = ""
    }
    
    func isMadeFromRootWord(_ word: String) -> Bool {
        var tempRootWord = rootWord.lowercased()

        for letter in word {
            if let index = tempRootWord.firstIndex(of: letter) {
                tempRootWord.remove(at: index)  // Remove used letter
            } else {
                return false  // Letter not found in rootWord
            }
        }
        return true
    }
    
    func isRealWord(_ word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")

        return misspelledRange.location == NSNotFound // **True if no spelling errors found**
    }

    func startGame() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL, encoding: .utf8) {
                let allWords = startWords.split(separator: "\n")
                rootWord = String(allWords.randomElement() ?? "silkworm")
                
                usedWords.removeAll()
                newWord = ""
                score = 0  // **Reset score when a new game starts**
                
                return
            }
        }
        fatalError("Could not load start.txt from bundle.")
    }
}

#Preview {
    ContentView()
}
