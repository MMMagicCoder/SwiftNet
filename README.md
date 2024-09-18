# SwiftNet

 ![](https://img.shields.io/badge/platform-iOS-d3d3d3) ![](https://img.shields.io/badge/iOS-14.0%2B-43A6C6) ![](https://img.shields.io/badge/Swift-5-F86F15)

`SwiftNet` is a Swift package designed to simplify networking operations in `SwiftUI`. It offers three flexible approaches for fetching, downloading, and uploading data or files using `Escaping Closures`, `Combine`, and `async-await` techniques, allowing you to choose the method that best suits your project requirements.

## Table of contents
   - [Requirements](#requirements)
   - [Installation](#installation)
     - [Swift Package Manager (SPM)](#spm)
   - [Usage](#usage)
     - [Fetching Data](#fetching)
     - [Downloading Files](#downloading)
     - [uploading Data](#uploading)
   - [Contribution](#contribution)
   - [License](#license)

## Requirements
<a id="requirements"></a>
   - SwiftUI
   - iOS 14.0 or above

## Installation
<a id="installation"></a>
You can access SwiftNet through [Swift Package Manager](https://github.com/apple/swift-package-manager).
### Swift Package Manager (SPM)
<a id="spm"></a>
In xcode select:
```
File > Swift Packages > Add Package Dependency...
```
Then paste this URL:
```
https://github.com/MMMagicCoder/SwiftNet.git
```

## Usage
<a id="usage"></a>
`SwiftNet` provides a streamlined way to perform networking tasks. Whether you're fetching small data, downloading large files, or uploading content, you can choose between Escaping Closures, Combine, or async-await methods. To use these methods, instantiate the appropriate manager:
- ```let networkManager = EscapingNetworkManager()``` for Escaping Closures.
- ```let networkManager = CombineNetworkManager()``` for Combine.
- ```let networkManager = AsyncNetworkManager()``` for async-await.
  
Below are examples for each type of task.

### Fetching Data
<a id="fetching"></a>

`SwiftNet` provides two types of data fetching: `JSON Fetching` and `Data Fetching`. For JSON fetching, your model must conform to the `FetchableModel` protocol, which ensures the proper structure for decoding JSON responses.

- JSON Fetching

You can fetch JSON data by using the following methods, depending on the approach you choose. Make sure your model conforms to FetchableModel:

```swift
struct DataModel: FetchableModel {
    let userId: Int
    let id: Int
    let title: String
    let body: String
}
```

Using Escaping Closures

```swift
 networkManager.fetchJSON(fromURL: "https://example.com/api/data") { (result: [MyModel]?, response, error) in
    if let result = result {
        // Handle the decoded JSON result
    } else if let error = error {
        // Handle the error
    }
}
```

Using Combine

```swift
  networkManager.fetchJSON(fromURL: url) { (returnedData: [DataModel]?, response, error) in
     if let result = result {
         // Handle the decoded JSON result
    } else if let error = error {
        // Handle the error
    }
}
```

Using async-await

```swift
Task {
    do {
        let result: [MyModel] = try await networkManager.fetchJSON(fromURL: "https://example.com/api/data")
        // Handle the decoded JSON result
    } catch {
        // Handle the error
    }
}
```

- Data Fetching

  Data fetching is used when you need to fetch raw data (e.g., images, binary files) without decoding it into a specific model.

  Using Escaping Closures

```swift
  networkManager.fetchData(fromURL: "https://example.com/file") { data, response, error in
    if let data = data {
        // Handle the fetched data
    } else if let error = error {
        // Handle the error
    }
}
```

Using Combine

```swift
 networkManager.fetchData(fromURL: url) { (returnedData, response, error) in
     if let result = result {
         // Handle the returned data
    } else if let error = error {
        // Handle the error
    }
}
```

Using async-await

```swift
Task {
    do {
        let data = try await networkManager.fetchData(fromURL: "https://example.com/file")
        // Handle the fetched data
    } catch {
        // Handle the error
    }
}
```

### Downloading Files
<a id="downloading"></a>

Using Escaping Closures Or Combine

```swift
networkManager.downloadData(fromURL: url) { tempLocalUrl, response, error in
    if let tempLocalUrl = tempLocalUrl {
       // Get data from tempLocalUrl url
  } else if error = error {
       // Handle the error
  }
}
```

Using async-await

```swift
Task {
    do {
        let fileURL = try await networkManager.downloadFile(using: .async)
        // Use the file
    } catch {
        // Handle the error
    }
}
```

### Uploading Data
<a id="uploading"></a>

Using Escaping Closures Or Combine

```swift
networkManager.uploadData(toURL: url, data: json, mimeType: .json) { response , error in
   if let error = error {
       // Handle the error
  } else {
       // Handle the response 
  }
}
```

Using async-await

```swift
  Task {
      do {
          let returnedResponse = try await networkManager.uploadData(toURL: url, data: json, mimeType: .json)
              // Handle the response
   } catch {
             // Handle the error
  }
}
```

### Contribution
<a id="contribution"></a> 
If you encounter any issues, feel free to open an issue. Contributions are also welcome, whether it's bug fixes, new features, or documentation improvements.

### License

<a id="license"></a> 
NetworkKit is distributed under the MIT License.
