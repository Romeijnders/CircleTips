import SwiftUI
import AirtableKit
import SDWebImageSwiftUI

struct Tip: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let rating: Int
    let address: String
    let googleMapsURL: String
}

class TipsViewModel: ObservableObject {
    @Published var tips: [Tip] = []

    func fetchTips() {
        let airtable = Airtable(apiKey: "keycaST0E770p7HWb", baseID: "appJYghlwwJ41QRkx")
        airtable.select(tableName: "Tips") { (result: Result<[Tip], Error>) in
            switch result {
                case .success(let tips):
                    DispatchQueue.main.async {
                        self.tips = tips
                    }
                case .failure(let error):
                    print("Error fetching tips: \(error)")
            }
        }
    }
}

struct ContentView: View {
    @StateObject private var viewModel = TipsViewModel()

    var body: some View {
        NavigationView {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(viewModel.tips) { tip in
                        TipView(tip: tip)
                    }
                }
                .padding()
            }
            .navigationTitle("City Tips")
            .onAppear {
                viewModel.fetchTips()
            }
        }
    }
}

struct TipView: View {
    let tip: Tip

    var body: some View {
        VStack(alignment: .leading) {
            WebImage(url: URL(string: "https://source.unsplash.com/random?city,\(tip.description)"))
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 300, height: 200)
                .cornerRadius(10)
                .overlay(RatingView(rating: tip.rating), alignment: .topTrailing)
            
            Text(tip.title)
                .font(.title2)
                .bold()
                .padding(.top)

            Text(tip.description)
                .font(.body)
                .padding(.top, 5)

            Button(action: {
                UIApplication.shared.open(URL(string: tip.googleMapsURL)!)
            }) {
                HStack {
                    Image(systemName: "map")
                    Text("Open in Google Maps")
                }
                .foregroundColor(.blue)
            }
            .padding(.top, 5)
        }
    }
}

struct RatingView: View {
    let rating: Int

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.black)
                .opacity(0.6)
                .frame(width: 40, height: 40)

            Text("\(rating)")
                .foregroundColor(.white)
                .bold()
        }
    }
}

@main
struct CityTipsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class TipsViewModel: ObservableObject {
    @Published var tips: [Tip] = []

    func fetchTips() {
        let url = "https://circletips.herokuapp.com//tips"
        URLSession.shared.dataTask(with: URL(string: url)!) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching tips: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            do {
                let tips = try JSONDecoder().decode([Tip].self, from: data)
                DispatchQueue.main.async {
                    self.tips = tips
                }
            } catch {
                print("Error decoding tips: \(error)")
            }
        }.resume()
    }
}
