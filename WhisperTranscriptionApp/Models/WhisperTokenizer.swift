import Foundation

class WhisperTokenizer {
    static let shared = WhisperTokenizer()
    
    private var tokenToIndexMap: [String: Int] = [:]
    private var indexToTokenMap: [Int: String] = [:]
    
    private init() {
        loadTokens()
    }
    
    func tokenize(_ text: String) throws -> [Int] {
        let tokens = text.components(separatedBy: .whitespacesAndNewlines)
        var tokenIndices: [Int] = []
        
        for token in tokens {
            if let index = tokenToIndexMap[token] {
                tokenIndices.append(index)
            } else {
                throw TokenizationError.tokenNotFound(token)
            }
        }
        
        return tokenIndices
    }
    
    func detokenize(_ indices: [Int]) -> String {
        let tokens = indices.compactMap { indexToTokenMap[$0] }
        return tokens.joined(separator: " ")
    }
    
    private func loadTokens() {
        guard let url = Bundle.main.url(forResource: "whisper_tokens", withExtension: "json") else {
            print("whisper_tokens.json not found")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let tokenDict = try JSONDecoder().decode([String: Int].self, from: data)
            self.tokenToIndexMap = tokenDict
            self.indexToTokenMap = tokenDict.reduce(into: [Int: String]()) { result, pair in
                result[pair.value] = pair.key
            }
        } catch {
            print("Error loading tokens: \(error)")
        }
    }
}

enum TokenizationError: Error {
    case tokenNotFound(String)
} 