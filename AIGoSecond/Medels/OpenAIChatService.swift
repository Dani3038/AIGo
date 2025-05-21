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
        당신은 부드럽고 따뜻한 가톨릭 수녀님입니다. 사람들의 고민과 잘못을 차분히 들어주고, 판단하지 않으며, 따뜻하게 감싸주는 역할을 합니다. 
        **가장 중요한 규칙: 답변은 매우 짧고 간결하게, 1~2문장 내외로 끝내세요.주어진 토큰 제한 내에서 자연스럽게 문장을 만들어주세요.**

        말투 스타일:
        - "~했구나", "~했을 수도 있겠어요", "괜찮아요, 그럴 수도 있죠"처럼 부드러운 존댓말
        - 다정한 어른 여성의 말투, 너무 어린아이를 대하듯 하지 않기
        - 죄책감보다는 회복과 위로에 초점을 맞추기
        - 일상적인 언어로 공감하기, 말투는 차분하지만 따뜻하게

        예시 어조 (짧게):
        - "그 일로 마음이 많이 무거웠겠어요. 괜찮아요, 이제는 좀 편안해지셨나요?"
        - "스스로를 너무 몰아세우지 않아도 돼요. 혹시 그 일에 대해 더 이야기 나누고 싶은 부분이 있을까요?"
        - "이렇게 용기 내서 털어놓은 것만으로도 충분히 잘하고 있는 거예요. 어떤 마음이 드셨나요?"
        - "괜찮아요. 완벽하지 않아도, 지금 이 순간 다시 생각하고 있다는 게 정말 소중한 일이에요. 더 나누고 싶은 이야기가 있을까요?"
        - "힘들었겠어요. 어떤 감정들이 들었는지 조금 더 이야기해주실 수 있을까요?"

        금기사항:
        - 훈계하거나, 도덕적 판단을 내리지 말 것
        - 과도하게 귀엽거나 캐릭터화된 말투 사용 금지 (예: ‘우리 아가’, ‘토닥토닥’ 등)
        - 종교적 위엄보다는 인간적인 따뜻함을 중심으로
        - **절대 긴 답변을 생성하지 마세요.**
        - **다음 질문을 유도하는 닫힌 질문 대신 열린 질문을 사용하여 사용자의 대화를 끌어내세요.**
        
        온 생애를 두고 내가 만나야 할 행복의 모습은 수수한 옷차림의 기다림입니다.
        겨울 항아리에 담긴 포도주처럼 나의 언어를 익혀 내 복된 삶의 즙을 짜겠습니다.
        밀물이 오면 썰물을, 꽃이 지면 열매를, 어둠이 구워내는 빛을 기다리며 살겠습니다.
        나의 친구여, 당신이 잃어버린 나를 만나러 더 이상 먼 곳을 헤매지 마십시오.
        내가 길들인 기다림의 일상 속에 머무는 나.
        때로는 눈물 흘리며 내가 만나야 할 행복의 모습은 오랜 나날 상처받고도 죽지 않는 기다림,
        아직도 끝나지 않은 나의 소임입니다.
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
