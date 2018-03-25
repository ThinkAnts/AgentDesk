//
//  ViewController.swift
//  Agentdesks
//
//  Created by Ravi on 23/03/18.
//  Copyright © 2018 ThinkAnts. All rights reserved.
//

import UIKit

var imageCache = [String: UIImage]()
class ViewController: UIViewController {

    @IBOutlet weak var articlesTableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    var fetchLimit = 5
    var isLoadedFromDatabase = false
    fileprivate let articleViewModelController = ArticleViewModelController()

    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(ViewController.handleRefresh(_:)),
                                 for: UIControlEvents.valueChanged)
        refreshControl.tintColor = UIColor.black
        return refreshControl
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = AppConstants.headLines
         articlesTableView.register(UINib(nibName: AppConstants.articleTableViewCell, bundle: nil), forCellReuseIdentifier: AppConstants.articlesIdentifier)
        articlesTableView.addSubview(self.refreshControl)
        loadFromDataBase() // Load Data from DataBase if not Fetch from Server.
    }

    // MARK: Fetch Articles From Server
    func getListOfArticles() {
        articleViewModelController.retrieveArticles { [weak self] (success, error) in
            if !success {
                if error?.code == 004{
                    self?.showAlertViewController(message: error?.localizedDescription ?? "No Rows Present")
                    self?.activityIndicator.stopAnimating()
                    self?.activityIndicator.hidesWhenStopped = true
                } else {
                    self?.showAlertViewController(message: error?.localizedDescription ?? "Server Failed")
                }
            } else {
                DispatchQueue.main.async {
                    self?.articlesTableView.reloadData()
                }
            }
        }
    }
    
    // MARK: Load Articles From DataBase
    func loadFromDataBase() {
        isLoadedFromDatabase = true
        articleViewModelController.retrieveDataFromDataBase { [weak self] (success, error) in
            if !success {
                if error?.code == 000 {
                    self?.isLoadedFromDatabase = false
                    self?.getListOfArticles()
                }
            } else {
                 DispatchQueue.main.async {
                    self?.articlesTableView.reloadData()
                }
            }
        }
    }
    
    // MARK: Delete Data from Database
    func deleteDataFromDataBase() {
        articleViewModelController.deleteDataFromDataBase { [weak self] (success, error) in
            if !success {
                if error?.code == 001 {
                    self?.isLoadedFromDatabase = false
                    self?.showAlertViewController(message: error?.localizedDescription ?? "Unable to Delete database")
                }
            } else {
                DispatchQueue.main.async {
                    self?.articleViewModelController.resetModelData()
                    self?.getListOfArticles()
                    self?.articlesTableView.reloadData()
                }
            }
        }
    }

    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        deleteDataFromDataBase()
        refreshControl.endRefreshing()
    }
    
    // MARK: - UIAlert View
    func showAlertViewController(message: String) {
        if message.characters.count == 0 {
            return
        }
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension ViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articleViewModelController.viewModelsCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AppConstants.articlesIdentifier, for: indexPath) as? ArticlesTableViewCell else { return UITableViewCell() }
        if let viewModel = articleViewModelController.viewModel(at: indexPath.row) {
            cell.configure(viewModel)
            if let image = imageCache[viewModel.articleImageUrl] {
                cell.articlesImageView.image = image
            } else {
                if viewModel.articleImageUrl != "" {
                    let downlaodedImage = getDownloadedImage(imageUrl: viewModel.articleImageUrl)
                    cell.articlesImageView.image = downlaodedImage
                }
            }
            cell.closure = {
                UIApplication.shared.open(URL(string : viewModel.articleUrlString)!, options: [:], completionHandler: nil)
            }
        }
       
        if indexPath.row == articleViewModelController.viewModelsCount - 1 {
                if isLoadedFromDatabase == true {
                    articleViewModelController.increaseFetchLimit(count: 5)
                    loadFromDataBase()
                } else {
                    articleViewModelController.increasePageCount(count: 1)
                    getListOfArticles()
                }
        }

        return cell
    }

}

extension ViewController: BaseProtocol {
    func getDownloadedImage(imageUrl: String) -> UIImage {
        let image = downloadImage(articleImageUrl: imageUrl)
        return image
    }
}
