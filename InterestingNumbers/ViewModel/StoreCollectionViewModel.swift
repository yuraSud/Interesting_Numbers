//
//  StoreCollectionViewModel.swift
//  Interesting_Numbers
//
//  Created by Yura Sabadin on 20.09.2023.
//
import Combine
import Foundation

final class StoreCollectionViewModel {
    
    @Published var products: [ProductModel] = []
    @Published var headers: [HeaderSectionModel] = []
    @Published var sectionsData: [[ProductModel]] = []
    @Published var error: Error?
    
    private let dataBase = DatabaseService.shared
    private let storageService = StorageService.shared
    private var dataSourceManager = DataSourceManager()
    private var subscribers = Set<AnyCancellable>()
    var url: URL?
    
    init() {
        sinkToCreateData()
    }
    
    private func sinkToCreateData() {
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
        getHeaders()
        getProducts()
    }
    
    func numberOfSections() -> Int {
        return sectionsData.count
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        return sectionsData[section].count
    }
    
    func getAllHtml() {
        storageService.downloadFileHtml { url in
            self.url = url
        }
    }
    
    private func getProducts() {
        Task {
            do {
                products = try await dataBase.getAllProducts()
            } catch let err {
                error = err
            }
        }
    }
    
    private func getHeaders() {
        Task {
            do {
                headers = try await dataBase.getAllHeaders()
            } catch let err {
                error = err
            }
        }
    }
}
