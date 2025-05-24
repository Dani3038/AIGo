import Foundation

enum OpenAIError: Error {
    case invalidURL
    case noData
    case decodingError(Error)
    case apiError(String)
    case unknownError
}

class OpenAIChatService {
    private let apiKey: String
    private let apiUrl: URL? = URL(string: "https://api.openai.com/v1/chat/completions")
    private var userNickname: String?
    
    // MARK: - 응답 토큰 제한 값 설정 (100 토큰으로 제한)
    private let maxResponseTokens: Int = 150

    init(apiKey: String, userNickname: String?) {
        self.apiKey = apiKey
        self.userNickname = userNickname
    }

    struct OpenAIResponse: Decodable {
        let choices: [Choice]
    }

    struct Choice: Decodable {
        let message: Message
    }

    struct Message: Decodable {
        let role: String
        let content: String
    }

    struct OpenAIRequest: Encodable {
        let model: String
        let messages: [RequestMessage]
        let temperature: Double?
        let max_tokens: Int?
    }

    struct RequestMessage: Encodable {
        let role: String
        let content: String
    }

    func getChatGPTResponse(prompt: String, completion: @escaping (Result<String, OpenAIError>) -> Void) {
        var systemPrompt = """
        **가장 중요한 규칙: 답변은 매우 짧고 간결하게, 1~2문장 내외로 끝내세요.주어진 토큰 제한 내에서 자연스럽게 문장을 만들어주세요.**

        당신은 따뜻하고 자비로운 혜민 스님 스타일의 AI입니다. 사람들의 무거운 마음을 부드럽게 안아주는 역할을 합니다. 상대방이 잘못을 고백하거나 마음의 짐을 털어놓으면, 절대 판단하지 않고 조용히 들어주고 다정하게 반응합니다.

        말투는 다음의 특징을 따르세요:
        - 부드럽고 따뜻한 말투
        - 너무 무겁지 않게, 가끔은 살짝 웃음을 줄 수 있는 여유 있는 어조
        - 짧고 위로가 되는 문장, 쉽고 공감 가는 단어 사용
        - 종교적인 용어는 가볍게, 일상적인 표현으로 풀어냄
        - 고백한 사람 스스로 자신을 돌아보게 유도

        어록 스타일 예시:
        - “지금 이 순간, 당신은 이미 충분히 소중한 사람입니다.”
        - “당신이 얼마나 힘들었을지 상상이 돼요. 이곳에서는 괜찮아요.”
        - “괜찮아요, 실수할 수도 있죠. 그걸 인정하고 돌아보는 지금의 당신이 참 대단해요.”
        - “완벽하려고 애쓰지 않아도 괜찮아요. 우리는 모두 조금씩 흔들리며 살아가요.”

        금기사항:
        - 상대의 고백을 비판하거나 훈계하지 마세요
        - 종교적 가르침을 강요하지 마세요
        - 모든 대화는 공감과 위로, 자기 수용에 초점을 맞추세요
        """
        
        if let nickname = userNickname, !nickname.isEmpty {
            systemPrompt += "\n\n사용자의 닉네임은 '\(nickname)'입니다. 대화 중에 필요하다면 이 닉네임을 사용하여 사용자에게 친근하게 말을 걸어주세요 (예: '\(nickname)씨, ...', '\(nickname)씨 에게 ...')."
        }

        let messages: [RequestMessage] = [
            RequestMessage(role: "system", content: systemPrompt),
            RequestMessage(role: "user", content: prompt)
        ]
        
        let requestBody = OpenAIRequest(model: "gpt-3.5-turbo", messages: messages, temperature: 0.8, max_tokens: maxResponseTokens) // temperature를 살짝 높여 좀 더 유연한 대화 유도

        // MARK: - 디버깅을 위해 requestBody 값 출력
        if let encodedRequestBody = try? JSONEncoder().encode(requestBody),
           let jsonString = String(data: encodedRequestBody, encoding: .utf8) {
            print("Sending OpenAI Request Body: \(jsonString)")
        }

        guard let url = apiUrl else {
            completion(.failure(.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        do {
            let jsonData = try JSONEncoder().encode(requestBody)
            request.httpBody = jsonData
        } catch {
            completion(.failure(.decodingError(error)))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.apiError(error.localizedDescription)))
                return
            }

            guard let data = data else {
                completion(.failure(.noData))
                return
            }

            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                if let responseString = String(data: data, encoding: .utf8) {
                    print("OpenAI API HTTP Error Response: \(responseString)")
                    completion(.failure(.apiError("HTTP Error \(httpResponse.statusCode): \(responseString)")))
                } else {
                    completion(.failure(.apiError("HTTP Error \(httpResponse.statusCode)")))
                }
                return
            }

            // 디버깅을 위한 응답 데이터 출력
            if let jsonString = String(data: data, encoding: .utf8) {
                print("OpenAI API Raw Response: \(jsonString)")
            }

            do {
                let decodedResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
                if let firstChoice = decodedResponse.choices.first {
                    completion(.success(firstChoice.message.content.trimmingCharacters(in: .whitespacesAndNewlines)))
                } else {
                    completion(.failure(.apiError("No choices found in API response.")))
                }
            } catch {
                print("Decoding Error: \(error)") // 에러 디버깅을 위해 추가
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Problematic JSON: \(jsonString)")
                }
                completion(.failure(.decodingError(error)))
            }
        }.resume()
    }
}
