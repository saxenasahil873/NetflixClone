//
//  HomeViewController.swift
//  Netflix Clone
//
//  Created by Sahil Saxena on 14/08/23.
//

import UIKit

enum Sections: Int {
    case TrendingMovies = 0
    case TrendingTv = 1
    case Popular = 2
    case Upcoming = 3
    case TopRated = 4
}

class HomeViewController: UIViewController {
    
    static let shared = HomeViewController()
    
    private var randomTrendingMovie: Title?
    private var headerView: HeroHeaderUIView?
    
    let sectionTitles: [String] = ["Trending Movies", "Trending TV","popular", "Upcoming Movies", "Top Rated"]
    
    private let homeFeedTable: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(CollectionViewTableViewCell.self, forCellReuseIdentifier: CollectionViewTableViewCell.identifier)
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(homeFeedTable)
//        view.backgroundColor = .systemBackground
        
        homeFeedTable.delegate = self
        homeFeedTable.dataSource = self
        
        configureNavbar()
        
        headerView = HeroHeaderUIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 450))
        homeFeedTable.tableHeaderView = headerView
        configureHeroHeaderView()
    }
    
    private func configureHeroHeaderView() {
        getMovieList {[weak self] isSuccess, response in
            if isSuccess, response != nil {
                let selectedTitle = response?.results.randomElement()
                self?.randomTrendingMovie = selectedTitle
                self?.headerView?.configure(with: TitleViewModel(titleName: selectedTitle?.original_title ?? "", posterURL: selectedTitle?.poster_path ?? ""))
            } else {
                print("error")
            }
        }
    }
    
    private func getMovieList(completionHandler: @escaping (Bool, MovieResponse?) -> Void) {
        let request = APICaller.shared.createRequest(with: Constants.moviesAPI, method: .get)
        APICaller.shared.executeRequest(with: request) { (isSuccess: Bool, response: MovieResponse?)in
            completionHandler(isSuccess, response)
        }
    }
    private func getTvList(completionHandler: @escaping (Bool, MovieResponse?) -> Void) {
        let request = APICaller.shared.createRequest(with: Constants.tvsAPI, method: .get)
        APICaller.shared.executeRequest(with: request) { (isSuccess: Bool, response: MovieResponse?) in
            completionHandler(isSuccess, response)
        }
    }
    func getUpcomingmoviesList(completionHandler: @escaping (Bool, MovieResponse?) -> Void) {
        let request = APICaller.shared.createRequest(with: Constants.upcomingMoviesAPI, method: .get)
        APICaller.shared.executeRequest(with: request) { (isSuccess: Bool, response: MovieResponse?) in
            completionHandler(isSuccess, response)
        }
    }
    private func getPopularList(completionHandler: @escaping (Bool, MovieResponse?) -> Void) {
        let request = APICaller.shared.createRequest(with: Constants.popularAPI, method: .get)
        APICaller.shared.executeRequest(with: request) { (isSuccess: Bool, response: MovieResponse?) in
            completionHandler(isSuccess, response)
        }
    }
    private func getTopRatedList(completionHandler: @escaping (Bool, MovieResponse?) -> Void) {
        let request = APICaller.shared.createRequest(with: Constants.topRatedAPI, method: .get)
        APICaller.shared.executeRequest(with: request) { (isSuccess: Bool, response: MovieResponse?) in
            completionHandler(isSuccess, response)
        }
    }
    
    private func configureNavbar() {
        var image = UIImage(named: "netflixLogo")
        image = image?.withRenderingMode(.alwaysOriginal)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .done, target: self, action: nil)
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: UIImage(systemName: "person"), style: .done, target: self, action: nil),
            UIBarButtonItem(image: UIImage(systemName: "play.rectangle"), style: .done, target: self, action: nil)
        ]
        navigationController?.navigationBar.tintColor = .white
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        homeFeedTable.frame = view.bounds
    }
    
}
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell =  tableView.dequeueReusableCell(withIdentifier: CollectionViewTableViewCell.identifier, for: indexPath) as? CollectionViewTableViewCell else {
            return UITableViewCell()
        }
        cell.delegate = self
        
        switch indexPath.section {
            
        case Sections.TrendingMovies.rawValue:
            getMovieList { isSuccess, response in
                if isSuccess, let tvShows = response?.results {
                    cell.configure(with: tvShows)
                    print(response?.results)
                } else {
                    debugPrint("TV List Service Error")
                }
            }
            
        case Sections.TrendingTv.rawValue:
            getTvList { isSuccess, response in
                if isSuccess, let tvShows = response?.results {
                    cell.configure(with: tvShows)
                } else {
                    debugPrint("TV List Service Error")
                }
            }
            
        case Sections.Popular.rawValue:
            getPopularList { isSuccess, response in
                if isSuccess, let tvShows = response?.results {
                    cell.configure(with: tvShows)
                } else {
                    debugPrint("TV List Service Error")
                }
            }
            
        case Sections.Upcoming.rawValue:
            getUpcomingmoviesList { isSuccess, response in
                if isSuccess, let tvShows = response?.results {
                    cell.configure(with: tvShows)
                } else {
                    debugPrint("TV List Service Error")
                }
            }
            
        case Sections.TopRated.rawValue:
            getTopRatedList { isSuccess, response in
                if isSuccess, let tvShows = response?.results {
                    cell.configure(with: tvShows)
                } else {
                    debugPrint("TV List Service Error")
                }
            }
        default:
            return UITableViewCell()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        header.textLabel?.frame = CGRect(x: header.bounds.origin.x, y: header.bounds.origin.y, width: 100, height: header.bounds.height)
        header.textLabel?.textColor = .white
        header.textLabel?.text = header.textLabel?.text?.capitalizedFirstLetter()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let defaultOffSet = view.safeAreaInsets.top
        let offSet = scrollView.contentOffset.y + defaultOffSet
        
        navigationController?.navigationBar.transform = .init(translationX: 0, y: -offSet)
    }
    
}

extension HomeViewController: CollectionViewTableViewCellDelegate {
    func CollectionViewTableViewCellDidTapCell(_ cell: CollectionViewTableViewCell, viewModel: TitlePreviewViewModel) {
        DispatchQueue.main.async {
            let vc = TitlePreviewViewController()
            vc.configure(with: viewModel)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
}
