import Foundation

fileprivate let responseCodes = 200..<300

enum URLErrors: Error {
    case errorData
    case errorNetwrk
    case errorCode(String)
    case noFound
}

extension URLSession {
    
    func dataTaskA(for urlRequest: URLRequest) async throws -> (Data, URLResponse) {
        try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                let task = dataTask(with: urlRequest) { data, response, error in
                    if let data, let httpResponse = response as? HTTPURLResponse {
                        if let error {
                            continuation.resume(throwing: error)
                        }
                        if responseCodes.contains(httpResponse.statusCode) {
                            continuation.resume(returning:( data,httpResponse))
                        } else {
                            let json = String(data: data, encoding: String.Encoding(rawValue: NSUTF8StringEncoding) )
                            if httpResponse.statusCode == 404 {
                                continuation.resume(throwing: URLErrors.noFound)
                            } else {
                                continuation.resume(throwing: URLErrors.errorCode(json!))
                            }
                        }
                    } else {
                        continuation.resume(throwing: URLErrors.errorData)
                    }
                }
                if Task.isCancelled == true {
                    task.cancel()
                } else {
                    task.resume()
                }
            }
        }
    onCancel:
        {
            print("task cancelled")
        }
    }
}
