//
//  EscapingFetching.swift
//
//
//  Created by mohammadmahdi moayeri on 8/22/24.
//

import Foundation

public Protocol FetchableModel: Identifiable, Codable {}

public class EscapingFetching<T: FetchableModel>: ObservableObject {
    @Published var dataModelItems: [T] = []
    
    public func fetchData(fromURL url: String) {
        guard let url = URL(string: url) else { return }
        
        NetworkManager.dataTask(fromURL: url) { returnedData in
            if let data = returnedData {
                guard let newDataModelItem = try? JSONDecoder().decode([T].self, from: data) else { return }
                
                DispatchQueue.main.async { [weak self] in
                    self?.dataModelItems = newDataModelItem
                }
            } else {
                print("Somthing went wrong during fetching data!!!")
            }
        }
    }
}
