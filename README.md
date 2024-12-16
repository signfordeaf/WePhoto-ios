# WePhoto

## 🛠️ Install Package    
### Swift Package Manager
Add this package to your project using Swift Package Manager in Xcode.

   1. Open your project in Xcode.
   2. Select **Add Packages** from the **File** menu.
   3. Enter the following GitHub repo URL:
        
    https://github.com/signfordeaf/WePhoto-ios.git
  
### Manual Installation

   1. Clone this repository.
   2. Copy it to your project and include the Swift files in the package into the project.

## ⚙️ Activation
Activate the package with the API key and request URL given to you on this page.
```swift
import WePhoto

@main
struct WeAccessExampleAppApp: App {
    
    init() {
        WePhotoInit.shared?.setApiKey("YOUR-API-KEY")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

```

## 🧑🏻‍💻 Usage

###  📄UIScreen.swift
```swift
...
import SignForDeaf
...

struct ContentView: View {

    var body: some View {
        VStack {
            ...
            WePhotoImageView(
                imageUrl: "https://picsum.photos/200",
                assetImageName: nil
            )
            .padding()
            WePhotoImageView(imageUrl: nil, assetImageName: "forest")
            .padding()
            ...
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
```
        

        

        
