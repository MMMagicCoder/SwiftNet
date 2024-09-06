import Foundation


public class EscapingDataManager {
    private let session: URLSession
    
    public init(session: URLSession) {
        self.session = session
    }
    
    public func fetchJSON<T: FetchableModel>(fromURL url: String, completionHandler: @escaping ([T]?, URLResponse?, Error?) -> ()) {
            guard let url = URL(string: url) else { return }
            
            let task = session.dataTask(with: url) { data, response, error in
                guard let data = data,
                      error == nil,
                      let response = response as? HTTPURLResponse,
                      response.statusCode >= 200 && response.statusCode < 300 else {
                    print("Error fetching data!!!: \(String(describing: error?.localizedDescription))")
                    completionHandler(nil, response, error)
                    return
                }
                
                do {
                    let decodedData = try JSONDecoder().decode([T].self, from: data)
                    completionHandler(decodedData, response, nil)
                } catch {
                    print("Error decoding Data!!!: \(String(describing: error.localizedDescription))")
                    completionHandler(nil, response, error)
                }
            }
            task.resume()
        }
    
    public func fetchData(fromURL url: String, completionHandler: @escaping (Data?, URLResponse?, Error?) -> ()) {
        guard let url = URL(string: url) else { return }
        
        let task = session.dataTask(with: url, completionHandler: { data, response, error in
            guard let data = data,
                  error == nil,
                  let response = response as? HTTPURLResponse,
                  response.statusCode >= 200 && response.statusCode < 300 else {
                print("Error fetching data!!!: \(String(describing: error?.localizedDescription))")
                completionHandler(nil, response, error)
                return
            }
            
            completionHandler(data, response, nil)
            return
        })
        task.resume()
    }
}
