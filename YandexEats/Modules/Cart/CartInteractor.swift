//
//  CartInteractor.swift
//  YandexEats
//
//  Created by Artemiy Zuzin on 03.09.2024.
//

import Foundation

//MARK: - Cart Interactor Protocol
/// протокол интерактора корзины, нужен для взаимодействия с данными
protocol CartInteractorProtocol {
    var cartManager: Cart { get set }
    var imageLoader: ImageLoaderProtocol { get set }
    
    func getCartItems() async throws -> [CartItem]
    func deleteCart() async throws
    func updateCartItem(item: CartItem) async throws
    func updateCartItem(items: [CartItem]) async throws
    func loadImage(from url: String) async throws -> Data
}

//MARK: - Cart Interactor
final class CartInteractor: CartInteractorProtocol {
    
    /// менеджер айтемов содержащихся в корзине
    var cartManager: any Cart
    /// загрузчик картинок
    var imageLoader: any ImageLoaderProtocol
    
    init(cartManager: any Cart, imageLoader: any ImageLoaderProtocol) {
        self.cartManager = cartManager
        self.imageLoader = imageLoader
    }
    
//    MARK: - Requests
    /// получить все айтемы корзины
    func getCartItems() async throws -> [CartItem] {
        try await self.cartManager.getCartItems()
    }
    
    /// удалить всей айтемы корзины
    func deleteCart() async throws {
        try await self.cartManager.deleteCart()
    }
    
    /// обновить айтем в корзине
    func updateCartItem(item: CartItem) async throws {
        try await self.cartManager.updateCartItem(item: item)
    }
    
    /// обновить некоторые айтемы корзины
    func updateCartItem(items: [CartItem]) async throws {
        try await self.cartManager.updateCartItem(items: items)
    }
    
//    MARK: - Image Loader
    /// загрузить картинку
    func loadImage(from url: String) async throws -> Data {
        try await self.imageLoader.load(from: url)
    }
    
}
