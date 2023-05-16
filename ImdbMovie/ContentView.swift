import SwiftUI

struct Movie: Codable {
    let title: String
    let poster: String
    let year: String
    
    enum CodingKeys: String, CodingKey {
        case title = "Title"
        case poster = "Poster"
        case year = "Year"
    }
}

struct ContentView: View {
    @State private var movies: [Movie] = []
    
    func fetchMovies() {
        guard let url = URL(string: "https://www.omdbapi.com/?s=Batman&page=1&apikey=eeefc96f") else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                return
            }
            
            do {
                let result = try JSONDecoder().decode(SearchResult.self, from: data)
                DispatchQueue.main.async {
                    self.movies = result.search
                }
            } catch {
                print(error.localizedDescription)
            }
        }.resume()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Color.gray
                Text("IMDB Clone")
                    .foregroundColor(.white)
                    .font(.title)
            }
            .frame(height: 42)
            .padding(.top, 16)
            
            List(movies, id: \.title) { movie in
                HStack {
                    if let url = URL(string: movie.poster), let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                        Image(uiImage: image)
                            .resizable()
                            .frame(width: 140, height: 210)
                            .cornerRadius(12)
                            .padding(.vertical, 16)
                            .padding(.leading, 5) // Updated padding from left to 5px
                    }
                    VStack(alignment: .leading) {
                        Text(movie.title)
                            .font(.headline)
                            .padding(.bottom,2)
                            .padding(.leading,10)
                        
                        Text(movie.year)
                            .font(.subheadline)
                            .padding(.bottom,120)
                            .padding(.leading,10)
                    }
                }
            }
            .listStyle(PlainListStyle())
        }
        .onAppear {
            fetchMovies()
        }
    }
    
    struct SearchResult: Codable {
        let search: [Movie]
        let totalResults: String
        let response: String
        
        enum CodingKeys: String, CodingKey {
            case search = "Search"
            case totalResults
            case response = "Response"
        }
    }
}

