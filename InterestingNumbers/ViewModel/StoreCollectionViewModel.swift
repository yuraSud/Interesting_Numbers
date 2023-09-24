//
//  StoreCollectionViewModel.swift
//  Interesting_Numbers
//
//  Created by Yura Sabadin on 20.09.2023.
//
import Combine
import Foundation

class StoreCollectionViewModel {
    
    @Published var products: [ProductModel] = []
    @Published var headers: [HeaderSectionModel] = []
    @Published var sectionsData: [[ProductModel]] = []
    @Published var error: Error?
    
    let dataBase = DatabaseService.shared
    let storageService = StorageService.shared
    var dataSourceManager = DataSourceManager()
    var subscribers = Set<AnyCancellable>()
    var url: URL?
    
    init() {
        sinkToCreateData()
    }
    
    func sinkToCreateData() {
        $products
            .filter{!$0.isEmpty }
            .sink { product in
                self.sectionsData = self.dataSourceManager.createDataSourceHeaderAndSections(products: product, headers: self.headers) { error in
                    self.error = error
                }
                self.headers = self.dataSourceManager.headerArray
        }
            .store(in: &subscribers)
    }
    
    func refreshDataFromInternet() {
        print("refresh headers and products")
        getHeaders()
        getProducts()
    }
    
    func numberOfSections() -> Int {
        return sectionsData.count
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        return sectionsData[section].count
    }
    
    func getProducts() {
        Task {
            do {
                products = try await dataBase.getAllProducts()
            } catch let err {
                error = err
            }
        }
    }
    
    func getHeaders() {
        Task {
            do {
                headers = try await dataBase.getAllHeaders()
            } catch let err {
                error = err
            }
        }
    }
    
    func getAllHtml() {
        storageService.downloadFileHtml { url in
            self.url = url
        }
    }
}
