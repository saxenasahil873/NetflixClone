//
//  SearchViewController.swift
//  Netflix Clone
//
//  Created by Sahil Saxena on 14/08/23.
//

import UIKit

class SearchViewController: UIViewController {
    
    private var titles:[Title] = [Title]()
    
    private let discoverTable: UITableView = {
        let table = UITableView()
        table.register(TitleTableViewCell.self, forCellReuseIdentifier: TitleTableViewCell.identifier)
        return table
    }()
    
    private let searchController: UISearchController = {
       let controller = UISearchController(searchResultsController: SearchResultViewController())
        controller.searchBar.placeholder = "Search"
        controller.searchBar.searchBarStyle = .minimal
        return controller
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Search"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        
        view.addSubview(discoverTable)
        discoverTable.delegate = self
        discoverTable.dataSource = self
        navigationItem.searchController = searchController
        navigationController?.navigationBar.tintColor = .white
        getDiscoverMoviesData()
        
        searchController.searchResultsUpdater = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        discoverTable.frame = view.bounds
    }
    
    func getDiscoverMoviesData() {
        self.getDiscoverMovies { isSuccess, response in
            if isSuccess, response != nil {
                self.titles = response?.results ?? []
                DispatchQueue.main.async {
                    self.discoverTable.reloadData()
                }
            } else {
                debugPrint("TV List Service Error")
            }
        }
    }
    
    func getDiscoverMovies(completionHandler: @escaping (Bool, MovieResponse?) -> Void) {
        let request = APICaller.shared.createRequest(with: Constants.discoverAPI, method: .get)
        APICaller.shared.executeRequest(with: request) { (isSuccess: Bool, response: MovieResponse?)in
            completionHandler(isSuccess, response)
        }
    }
    
    private func getSearchResult(with query: String, completionHandler: @escaping (Bool, MovieResponse?) -> Void) {
        guard let query = query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            return
        }
        let request = APICaller.shared.createRequest(with: "https://api.themoviedb.org/3/search/movie?query=\(query)&api_key=2fca19f8571cc003ccadbb91608b996e", method: .get)
        APICaller.shared.executeRequest(with: request) { (isSuccess: Bool, response: MovieResponse?) in
            completionHandler(isSuccess, response)
        }
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TitleTableViewCell.identifier, for: indexPath) as? TitleTableViewCell else {
            return UITableViewCell()
        }
        
        let title = titles[indexPath.row]
        let model = TitleViewModel(titleName: title.original_name ?? title.original_title ?? "unknown title name", posterURL: title.poster_path ?? "")
        cell.configure(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let title = titles[indexPath.row]
        
        guard let titleName = title.original_title ?? title.original_name else {
            return
        }
        APICaller.shared.getMovie(with: titleName) { [weak self] isSuccess, videoElement in
            if isSuccess, videoElement != nil {
                DispatchQueue.main.async {
                    let vc = TitlePreviewViewController()
                    vc.configure(with: TitlePreviewViewModel(title: titleName, youtubeView: videoElement!, titleOverview: title.overview ?? ""))
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
                
            }
            else {
                print("error")
            }
        }
    }
}

extension SearchViewController: UISearchResultsUpdating, SearchResultViewControllerDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        
        guard let query = searchBar.text, !query.trimmingCharacters(in: .whitespaces).isEmpty, query.trimmingCharacters(in: .whitespaces).count >= 3, let resultController = searchController.searchResultsController as? SearchResultViewController else {
            return
        }
        resultController.delegate = self
        
        getSearchResult(with: query) { isSuccess, response in
            if isSuccess, response != nil {
                resultController.titles = response?.results ?? []
                resultController.searchResultCollectionView.reloadData()
            } else {
                debugPrint("TV List Service Error")
            }
        }
        
    }
    
    func searchResultViewControllerDidTapItem(_ viewModel: TitlePreviewViewModel) {
        
        DispatchQueue.main.async { [weak self] in
            let vc = TitlePreviewViewController()
            vc.configure(with: viewModel)
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
}
