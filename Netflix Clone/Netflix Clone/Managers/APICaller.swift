//
//  APICaller.swift
//  Netflix Clone
//
//  Created by Sahil Saxena on 16/08/23.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}
enum APIError: Error {
    case failedToGetData
}

struct Constants {
    static let API_KEY = "2fca19f8571cc003ccadbb91608b996e"
    static let baseURL = "https://api.themoviedb.org"
    static let moviesAPI = "\(baseURL)/3/trending/movie/day?api_key=\(API_KEY)"
    static let tvsAPI = "\(baseURL)/3/trending/tv/day?api_key=\(API_KEY)"
    static let upcomingMoviesAPI = "\(baseURL)/3/movie/upcoming?api_key=\(API_KEY)&languages=en-US&page=1"
    static let popularAPI = "\(baseURL)/3/movie/popular?api_key=\(API_KEY)&languages=en-US&page=1"
    static let topRatedAPI = "\(baseURL)/3/movie/top_rated?api_key=\(API_KEY)&languages=en-US&page=1"
    static let discoverAPI = "\(baseURL)/3/discover/movie?api_key=\(API_KEY)&languages=en-US&sort_by=popularity.desc&include_adult=false&include_video=false&age=1&with_watch_monetization_types=flatrate"
    static let YoutubeKey = "AIzaSyD4zSs73T0KapYWYh6sLjSPf1dvwp8wI30"
    static let youtubeBaseUrl = "https://youtube.googleapis.com/youtube/v3/search?"
}

class APICaller {
    static let shared: APICaller = APICaller()
    var urlSession: URLSession = URLSession(configuration: URLSessionConfiguration.default)
    
    private init() {
        ///Initialise any default values if needed
    }
    
    func createRequest(with urlString: String, method: HTTPMethod) -> URLRequest? {
        if let url = URL(string: urlString) {
            var request = URLRequest(url: url)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = method.rawValue
            return request
        }
        return nil
    }
    
    func executeRequest<T: Codable>(with request: URLRequest?, completionHandler: @escaping (Bool, T?) -> Void) {
        guard request != nil else {
            DispatchQueue.main.async {
                completionHandler(false, nil)
            }
            return
        }
        let dataTask = self.urlSession.dataTask(with: request!) { data, response, error in
            guard error == nil else {
                DispatchQueue.main.async {
                    completionHandler(false, nil)
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                DispatchQueue.main.async {
                    completionHandler(false, nil)
                }
                return
            }
            
            guard let resData = data else {
                DispatchQueue.main.async {
                    completionHandler(false, nil)
                }
                return
            }
            
            if let codableRepsone = try? JSONDecoder().decode(T.self, from: resData) {
                DispatchQueue.main.async {
                    completionHandler(true, codableRepsone)
                }           
            }
            else {
                DispatchQueue.main.async {
                    completionHandler(false, nil)
                }
            }
        }
        dataTask.resume()
    }
    
    //For Youtube page
    func getMovie(with query: String, completionHandler: @escaping(Bool, VideoElement?) -> Void) {
        guard let query = query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else { return }
        let request = createRequest(with: "\(Constants.youtubeBaseUrl)q=\(query)&key=\(Constants.YoutubeKey)", method: .get)
        executeRequest(with: request) { (isSuccess: Bool, response: YoutubeSearchResponse?) in
            completionHandler(isSuccess, response?.items[0])
        }
    }
    
}

