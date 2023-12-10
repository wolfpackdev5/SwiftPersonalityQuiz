import SwiftUI
import Combine
import Foundation
import UIKit
import CoreGraphics

/*
 This SwiftUI view is a personality quiz. It will present a series of questions to the user and based on their responses, it will present a result. The quiz will be presented in a PageView, and each question will be a separate page. Each question will have multiple choice answers. The user's responses will be stored and used to calculate the result. Unsplash images are used as placeholders for each question. The answers are now separated in boxes for better user experience. The updated functionality includes moving to the next question after an answer is selected. The title of the quiz is now centered and its font size has been increased.
*/

struct ContentView: View {
    // The questions for the quiz
    let questions: [Question] = [
        Question(text: "Which food do you like the most?", answers: ["Steak", "Fish", "Carrots", "Corn"], image: "https://source.unsplash.com/random/food"),
        Question(text: "Which activity do you enjoy?", answers: ["Swimming", "Sleeping", "Cuddling", "Eating"], image: "https://source.unsplash.com/random/activity"),
        Question(text: "What is your favorite color?", answers: ["Red", "Green", "Blue", "Yellow"], image: "https://source.unsplash.com/random/color"),
       Question(text: "What is your favorite season?", answers: ["Spring", "Summer", "Autumn", "Winter"], image: "https://source.unsplash.com/random/season"),
        Question(text: "What is your favorite animal?", answers: ["Dog", "Cat", "Bird", "Fish"], image: "https://source.unsplash.com/random/animal")
    ]
    
    // The user's responses to the questions
    @State private var responses = [String]()
    @State private var selectedTab = 0
    var body: some View {
        NavigationView {
            TabView(selection: $selectedTab) {
                ForEach(questions.indices) { index in
                    VStack(alignment: .leading) {
                        RemoteImage(url: self.questions[index].image)
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 300, height: 200, alignment: .center)
                            .clipped()
                        Text(self.questions[index].text)
                        ForEach(self.questions[index].answers, id: \.self) { answer in
                           Button(action: {
                                self.responses.append(answer)
                                if index != self.questions.count - 1 {
                                    self.selectedTab = index + 1
                                }
                            }) {
                                Text(answer)
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(10)
                            }
                            .foregroundColor(.black)
                        }
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle())
        }
    }
}

struct Question {
    let text: String
    let answers: [String]
    let image: String
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct RemoteImage: View {
    private enum LoadState {
        case loading, success, failure
    }

    private class Loader: ObservableObject {
        var data = Data()
        var state = LoadState.loading

        init(url: String) {
            guard let parsedURL = URL(string: url) else {
                fatalError("Invalid URL: \(url)")
            }

            URLSession.shared.dataTask(with: parsedURL) { data, response, error in
                if let data = data, data.count > 0 {
                    self.data = data
                    self.state = .success
                } else {
                    self.state = .failure
                }

                DispatchQueue.main.async {
                    self.objectWillChange.send()
                }
            }.resume()
        }
    }

    @StateObject private var loader: Loader
    var image: UIImage?

    init(url: String) {
        _loader = StateObject(wrappedValue: Loader(url: url))
        image = UIImage(data: loader.data)
    }

    var body: some View {
        selectImage()
            .resizable()
    }

    @ViewBuilder
    private func selectImage() -> Image {
        switch loader.state {
        case .loading:
            return Image(systemName: "photo")
        case .failure:
            return Image(systemName: "multiply.circle")
        default:
            if let image = UIImage(data: loader.data) {
                return Image(uiImage: image)
            } else {
                return Image(systemName: "xmark.circle")
            }
        }
    }
}
