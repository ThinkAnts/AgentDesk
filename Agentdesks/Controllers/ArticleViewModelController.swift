//
//  ArticleViewModelController.swift
//  Agentdesks
//
//  Created by Ravi on 24/03/18.
//  Copyright © 2018 ThinkAnts. All rights reserved.
//

import UIKit
import CoreData

typealias RetrieveArticlesCompletionBlock = (_ success: Bool, _ error: NSError?) -> Void
class ArticleViewModelController {
    private static let pageSize = 5
    private var viewModels: [ArticleViewModel?] = []
    private var currentPage = 1
    private var fetchLimit = 5
    lazy var apiClient = {
        return APIClient<ArticlesAPI>()
    }()
    private var retrieveArticlesCompletionBlock: RetrieveArticlesCompletionBlock?
 
    var viewModelsCount: Int {
        return viewModels.count
    }
    
    func increasePageCount(count: Int) {
        currentPage = currentPage + count
    }
    
    func increaseFetchLimit(count: Int) {
        fetchLimit = fetchLimit + count
    }

    func resetModelData() {
        viewModels.removeAll()
    }

    func viewModel(at index: Int) -> ArticleViewModel? {
        return viewModels[index]
    }
    
    static func initViewModels(_ articles: [Article?]) -> [ArticleViewModel?] {
        return articles.map { article in
            if let article = article {
                return ArticleViewModel(article: article)
            } else {
                return nil
            }
        }
    }
    
    // MARK: API Call
    
    func retrieveArticles(_ completionBlock: @escaping RetrieveArticlesCompletionBlock) {
        retrieveArticlesCompletionBlock = completionBlock
        loadNextPageIfNeeded(for: currentPage)
    }
    
    func retrieveDataFromDataBase(_ completionBlock: @escaping RetrieveArticlesCompletionBlock) {
        retrieveArticlesCompletionBlock = completionBlock
        fetchData(fetchLimit: fetchLimit)
    }
    
    func deleteDataFromDataBase(_ completionBlock: @escaping RetrieveArticlesCompletionBlock) {
        retrieveArticlesCompletionBlock = completionBlock
        deleteAllData()
    }

    func loadNextPageIfNeeded(for index: Int) {
        apiClient.request(target: .getArticlesList(count: String(index), pageSize: "5"), success: { [weak weakself = self] responseObject in
            let articles = Articles(JSON:responseObject!)
            if articles?.articles.count == 0 {
                DispatchQueue.main.async {
                let error = NSError(domain: "", code: 004, userInfo: [NSLocalizedDescriptionKey : "No Rows Fetched"])
                weakself?.retrieveArticlesCompletionBlock?(false, error)
                }
            } else {
                let newArticlePage = ArticleViewModelController.initViewModels((articles?.articles)!)
                weakself?.loadData(articleList: (articles?.articles)!)
                weakself?.viewModels.append(contentsOf: newArticlePage)
                DispatchQueue.main.async {
                    weakself?.retrieveArticlesCompletionBlock?(true, nil)
                }
            }
        }, progress: nil) { [weak weakself = self] status in
            DispatchQueue.main.async {
                let error = NSError(domain: "", code: 002, userInfo: [NSLocalizedDescriptionKey : status.description])
                weakself?.retrieveArticlesCompletionBlock?(false, error)
            }
        }
    }
}

// MARK: CoreData Methods

extension ArticleViewModelController {
    func loadData(articleList: [Article?]) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let articleEntity = NSEntityDescription.entity(forEntityName: "ArticlesList", in: managedContext)!
        for article in articleList {
            let articleObject = NSManagedObject(entity: articleEntity, insertInto: managedContext)
            articleObject.setValue(article?.title, forKey: "title")
            articleObject.setValue(article?.description, forKey: "descriptionText")
            articleObject.setValue(article?.url, forKey: "urlString")
            articleObject.setValue(article?.imageUrl, forKey: "imageUrlString")
            managedContext.insert(articleObject)
        }
        DispatchQueue.main.async {
        do {
            try managedContext.save()
        } catch {
            print("Failed saving")
         }
        }
    }
    
    // 1.Fetch
    func fetchData(fetchLimit: Int) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let articleFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "ArticlesList")
        articleFetch.fetchLimit = fetchLimit
        var result = [NSManagedObject]()
        let records = try! managedContext.fetch(articleFetch)
        if let records = records as? [NSManagedObject] {
            result = records
        }
        if result.count > 0 {
            if let artilcesList = result as? [ArticlesList] {
                convertToDataObject(articleList: artilcesList)
            }
        } else {
            DispatchQueue.main.async { [unowned self] in
                let error = NSError(domain: "", code: 000, userInfo: [NSLocalizedDescriptionKey : "DataBase is Empty"])
                self.retrieveArticlesCompletionBlock?(false, error)
            }
        }
        
    }
    
    func convertToDataObject(articleList: [ArticlesList]) {
        var retrievedArticles: [Article?] = []
        for article in articleList {
            var fetchedArticle = Article()
            fetchedArticle.title = article.title!
            fetchedArticle.description = article.descriptionText!
            fetchedArticle.imageUrl = article.imageUrlString!
            fetchedArticle.url = article.urlString!
            retrievedArticles.append(fetchedArticle)
        }
        let newArticlePage = ArticleViewModelController.initViewModels(retrievedArticles)
        viewModels.append(contentsOf: newArticlePage)
        DispatchQueue.main.async { [unowned self] in
            self.retrieveArticlesCompletionBlock?(true, nil)
        }
    }
    
    // 2.Delete
    func deleteAllData()
    {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        // Create Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ArticlesList")
        // Create Batch Delete Request
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try managedContext.execute(batchDeleteRequest)
            DispatchQueue.main.async { [unowned self] in
                self.retrieveArticlesCompletionBlock?(true, nil)
            }
        } catch {
            DispatchQueue.main.async { [unowned self] in
                let error = NSError(domain: "", code: 001, userInfo: [NSLocalizedDescriptionKey : "Unable To Clear data"])
                self.retrieveArticlesCompletionBlock?(false, error)
            }
        }
    }
}

