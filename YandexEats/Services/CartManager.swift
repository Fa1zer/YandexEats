//
//  CartManager.swift
//  YandexEats
//
//  Created by Artemiy Zuzin on 03.09.2024.
//

import Foundation

//MARK: - Cart Protocol
protocol Cart {
 
    /**
     * Возвращает список всех элементов в корзине
     */
    func getCartItems() async throws -> [CartItem]

    /**
     * Удаляет корзину
     */
    func deleteCart() async throws

    /**
     * Обновляет элемент корзины
     */
    func updateCartItem(item: CartItem) async throws

    /**
     * Обновляет элементы корзины
     */
    func updateCartItem(items: [CartItem]) async throws

}
//MARK: - Mock
/// менеджер корзины
final class CartManagerMock: Cart {
    
    /// зранилище эктор, из которого мы берем все айтемы
    private var storage: CartItmesStorage
    
    init(storage: CartItmesStorage) {
        self.storage = storage
    }
    
    static let shared = CartManagerMock(storage: CartItemsStorageMock.shared)
    
//    MARK: - Get Methods
    /// получить все айтемы
    func getCartItems() async throws -> [CartItem] {
        await self.storage.items
    }
    
//    MARK: - Editing Methods
    /// удалить все айтемы
    func deleteCart() async throws {
        guard await !self.storage.items.isEmpty else { throw CartManagerError.cartIsAlreadyEmpty }
        
        await self.storage.deleteAllCartItems()
    }
    
    /// безопасно обновить один айтем
    func updateCartItem(item: CartItem) async throws {
        try await self.storage.updateCartItem(item: item)
    }
    
    /// безопасно обновить некоторые айтемы
    func updateCartItem(items: [CartItem]) async throws {
        try await self.storage.updateCartItem(items: items)
    }
    
}
