# SwiftNet

 ![](https://img.shields.io/badge/platform-iOS-d3d3d3) ![](https://img.shields.io/badge/iOS-14.0%2B-43A6C6) ![](https://img.shields.io/badge/Swift-5-F86F15)

`NetworkKit` is a Swift package designed to simplify networking operations in `SwiftUI`. It offers three flexible approaches for fetching, downloading, and uploading data or files using `Escaping Closures`, `Combine`, and `async-await` techniques, allowing you to choose the method that best suits your project requirements.

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

Fetching Data
<a id="fetching-data"></a>

`SwiftNet` provides two types of data fetching: `JSON Fetching` and `Data Fetching`. For JSON fetching, your model must conform to the `FetchableModel` protocol, which ensures the proper structure for decoding JSON responses.



