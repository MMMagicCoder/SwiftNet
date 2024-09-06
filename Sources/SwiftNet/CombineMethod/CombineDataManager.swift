import Foundation
import Combine

public class CombineDataManager {
    private let session: URLSession
    var cancellables = Set<AnyCancellable>()
    
    
    public init(session: URLSession) {
        self.session = session
    }
    
//    MARK: - Public Methods
    public func fetchJSON<T: FetchableModel>(fromURL url: String, completionHandler: @escaping ([T]?, URLResponse?, Error?) -> ()) {
       configureDataTaskPublisher(fromURL: url, completionHandler: completionHandler)
    }
    
    public func fetchData(fromURL url: String, completionHandler: @escaping (Data?, URLResponse?, Error?) -> ()) {
      configureDataTaskPublisher(fromURL: url, completionHandler: completionHandler)
    }
    
//    MARK: - Private Methods
    private func configureDataTaskPublisher<T: FetchableModel>(fromURL url: String, completionHandler: @escaping ([T]?, URLResponse?, Error?) -> ()) {
        guard let url = URL(string: url) else {
            completionHandler(nil, nil, URLError(.badURL))
            return
        }
        
        session.dataTaskPublisher(for: url)
            .receive(on: DispatchQueue.main)
            .tryMap { data, response -> (Data, URLResponse) in
                guard let response = response as? HTTPURLResponse,
                      response.statusCode >= 200 && response.statusCode < 300 else {
                    throw URLError(.badServerResponse)
                }
                return (data, response)
            }
            .flatMap { data, response -> AnyPublisher<([T], URLResponse), Error> in
                // Decode the data and return a publisher that outputs a tuple of decoded data and response
                Just(data)
                    .decode(type: [T].self, decoder: JSONDecoder())
                    .map { ($0, response) }
                    .mapError { $0 as Error }
                    .eraseToAnyPublisher()
            }
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("Finished fetching JSON")
                case .failure(let error):
                    print("Failed to fetch JSON: \(error)")
                    completionHandler(nil, nil, error)  // Pass the error to the handler
                }
            }, receiveValue: { returnedData, response in
                completionHandler(returnedData, response, nil)  // Pass the data and response with no error
            })
            .store(in: &cancellables)
    }
    
    private func configureDataTaskPublisher(fromURL url: String, completionHandler: @escaping (Data?, URLResponse?, Error?) -> ()) {
        guard let url = URL(string: url) else {
            completionHandler(nil, nil, URLError(.badURL))
            return
        }
        
        session.dataTaskPublisher(for: url)
            .receive(on: DispatchQueue.main)
            .tryMap { (data, response) -> (Data, URLResponse) in
                guard let response = response as? HTTPURLResponse,
                      response.statusCode >= 200 && response.statusCode < 300 else {
                    throw URLError(.badServerResponse)
                }
                return (data, response)
            }
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print("Error fetching data: \(error.localizedDescription)")
                    completionHandler(nil, nil, error)
                case .finished:
                    print("Finished fetching data.")
                }
            } receiveValue: { (returnedData, response) in
                completionHandler(returnedData, response, nil)
            }
            .store(in: &cancellables)
    }
}
