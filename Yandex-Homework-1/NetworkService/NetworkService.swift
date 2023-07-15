import Foundation
extension NSNotification.Name {
    static let activeRequestsChanged = NSNotification.Name("activeRequestsChanged")
}
enum NetworkServiceError: Error {
    case unableToMakeRequestURL
    case recipesDataMissing
    case imageDataMissing
    case brokenImageData
}

protocol INetworkService {
    func getList() async throws -> [Todomodel]
    func getElement(by id: String) async throws -> Todomodel
    func removeElement(by id: String) async throws -> Todomodel
    func updateList(list: [Todomodel]) async throws -> [Todomodel]
    func uploadItem(item: Todomodel) async throws
    func updateElement(elment: Todomodel) async throws
}

final class NetworkService {
    
    var revisionVersion = 0

    enum Endpoints {
        static let baseurl = "https://beta.mrdekk.ru/todobackend"
        static let list = "list"
        static let okStatus = "ok"
        static let authMethod = "Bearer"
        static let getMethod = "GET"
        static let authToken = "chowdering"
        static let authHTTPHeaderField = "Authorization"
        static let headerRevision = "X-Last-Known-Revision"
        static var headers = [
            Endpoints.headerRevision: "0",
        ]
    }
    enum httpTypes: String {
        case get
        case post
        case delete
        case put
        case PATCH
    }
}

//MARK: - Private

private extension NetworkService {

    private func makeURLReques(withHttpType httptype: httpTypes,
                       revision: Int? = nil,
                       id: String? = nil,
                       httpBody: Data? = nil) -> URLRequest?
    {
        var headerRevision = Endpoints.headers
        var string = "/\(Endpoints.list)"
        if let id {
            string.append("/\(id)")
        }
        guard let components = URLComponents(string: Endpoints.baseurl+"\(string)") else {
            return nil
        }
        guard let url = components.url  else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = httptype.rawValue
        
        request.setValue("\(Endpoints.authMethod) \(Endpoints.authToken)", forHTTPHeaderField: Endpoints.authHTTPHeaderField)
        if let httpBody {
            request.httpBody = httpBody
        }
        if let revision {
            headerRevision[Endpoints.headerRevision] = String(revision)
        }
        //Endpoints.headers[Endpoints.headerRevision] = String(revision ?? 0)
        request.timeoutInterval = 30
        request.allHTTPHeaderFields = headerRevision//Endpoints.headers
        return request
    }
}

//MARK: - INetworkService protocol

extension NetworkService: INetworkService {
    
    func getList() async throws -> [Todomodel] {
        guard let urlRequest = NetworkService().makeURLReques(withHttpType: .get) else {
            throw ((NetworkServiceError.unableToMakeRequestURL))
        }
        let (data, _) = try await URLSession.shared.dataTaskA(for: urlRequest)
        let response = try JSONDecoder().decode(ServerTodoListResponseDTO.self, from: data)
        revisionVersion = response.revision
        return response.list
    }
    
    func getElement(by id: String) async throws -> Todomodel {
        guard let urlRequest = NetworkService().makeURLReques(withHttpType: .get, id: id) else {
            throw ((NetworkServiceError.unableToMakeRequestURL))
        }
        let (data, _) = try await URLSession.shared.dataTaskA(for: urlRequest)
        let response = try JSONDecoder().decode(ServerTodoElementResponseDTO.self, from: data)
        revisionVersion = response.revision
        return response.element
    }
 
    func removeElement(by id: String) async throws -> Todomodel {
        guard let urlRequest = NetworkService().makeURLReques(withHttpType: .delete,revision:   revisionVersion, id: id) else {
            throw ((NetworkServiceError.unableToMakeRequestURL))
        }
        let (data, _) = try await URLSession.shared.dataTaskA(for: urlRequest)
        let response = try JSONDecoder().decode(ServerTodoElementResponseDTO.self, from: data)
        revisionVersion = response.revision
        return response.element
    }

    func updateList(list: [Todomodel]) async throws -> [Todomodel] {
        let reqst = ServerTodoListRequestDTO(status: Endpoints.okStatus, list: list)
        let body = try JSONEncoder().encode(reqst)
        guard let urlRequest = NetworkService().makeURLReques(withHttpType: .PATCH,revision:   revisionVersion, httpBody: body) else {
            throw ((NetworkServiceError.unableToMakeRequestURL))
        }
        let (data, _) = try await URLSession.shared.dataTaskA(for: urlRequest)
        let response = try JSONDecoder().decode(ServerTodoListResponseDTO.self, from: data)
        
        return response.list
    }

    func uploadItem(item: Todomodel) async throws{
        var request = ServerTodoElementRequestDTO(status: Endpoints.okStatus, element: item)
        let body = try JSONEncoder().encode(request)
        guard let urlRequest = NetworkService().makeURLReques(withHttpType: .post,revision: revisionVersion,httpBody: body) else {
            throw ((NetworkServiceError.unableToMakeRequestURL))
        }
            let (data, _) = try await URLSession.shared.dataTaskA(for: urlRequest)
            let response = try JSONDecoder().decode(ServerTodoElementResponseDTO.self,from: data)
            revisionVersion = response.revision
    }

    func updateElement(elment: Todomodel) async throws {
        var request = ServerTodoElementRequestDTO(status: Endpoints.okStatus, element: elment)
        let body = try JSONEncoder().encode(request)
        guard let urlRequest = NetworkService().makeURLReques(withHttpType: .put,revision:   revisionVersion,
                                                              id: elment.id,
                                                              httpBody: body) else {
            throw ((NetworkServiceError.unableToMakeRequestURL))
        }
        let (data, _) = try await URLSession.shared.dataTaskA(for: urlRequest)
        let response = try JSONDecoder().decode(ServerTodoElementResponseDTO.self,from: data)
        revisionVersion = response.revision
    }
}

