//
//  CartPresenter.swift
//  YandexEats
//
//  Created by Artemiy Zuzin on 03.09.2024.
//

import UIKit

//MARK: - Protocol
/// протокол презентера корзины, нужен для взаимодействия с интерактором и роутером, и для подготовоки данных к представлению
protocol CartPresenterProtocol {
    var router: CartRouterProtocol { get set }
    var interactor: CartInteractorProtocol { get set }
    var items: [CartItem] { get }
    var totalPrice: Int { get }
    var currency: String? { get }
    
    func getCartItems(onSucces: @escaping () -> Void, onError: @escaping (Error) -> Void)
    func deleteCart(onSucces: @escaping () -> Void, onError: @escaping (Error) -> Void)
    func updateCartItem(item: CartItem, onSucces: @escaping () -> Void, onError: @escaping (Error) -> Void)
    func updateCartItem(items: [CartItem], onSucces: @escaping () -> Void, onError: @escaping (Error) -> Void)
    func getSuccesPurchaseAlert() -> UIAlertController
    func getErrorAlert() -> UIAlertController
    func getBackAlert() -> UIAlertController
    func getDeleteItemsAlert(onDelete: @escaping () -> Void) throws -> UIAlertController
    func loadImage(from url: String) async throws -> Data
}

//MARK: - Cart Presenter
final class CartPresenter: CartPresenterProtocol {
    /// роутер
    var router: any CartRouterProtocol
    /// интерактор
    var interactor: any CartInteractorProtocol
    /// все айтемы корзины
    private(set) var items = [CartItem]()
    /// итоговая цена
    private(set) var totalPrice = Int.zero
    /// текущая валюта
    private(set) var currency: String?
    
//    MARK: - Init
    init(router: any CartRouterProtocol, interactor: any CartInteractorProtocol) {
        self.router = router
        self.interactor = interactor
    }
    
//    MARK: - Request
    /// получаем все айтемы
    func getCartItems(onSucces: @escaping () -> Void = { }, onError: @escaping (any Error) -> Void = { _ in }) {
        Task(priority: .background) { [ weak self ] in
            guard let self else { return }
            
            do {
                self.items = try await self.interactor.getCartItems()
                /// также обновляем остальные нужные нам данные
                self.currency = self.items.first?.currency
                self.totalPrice = .zero
                
                for item in self.items {
                    self.totalPrice += (item.price * item.count)
                }
                
                DispatchQueue.main.async {
                    onSucces()
                }
            } catch {
                print("❌ ERROR: \(#file), \(#function): \(error.localizedDescription)")
                DispatchQueue.main.async {
                    onError(error)
                }
            }
        }
    }
    
    /// удаляем все айтемы
    func deleteCart(onSucces: @escaping () -> Void = { }, onError: @escaping (any Error) -> Void = { _ in }) {
        Task(priority: .background) { [ weak self ] in
            guard let self else { return }
            
            do {
                try await self.interactor.deleteCart()
                /// так же сразу обнуляем все данные
                self.items = .init()
                self.currency = nil
                self.totalPrice = .zero
                DispatchQueue.main.async {
                    onSucces()
                }
            } catch {
                print("❌ ERROR: \(#file), \(#function): \(error.localizedDescription)")
                DispatchQueue.main.async {
                    onError(error)
                }
            }
        }
    }
    
    /// обновляем один айтем
    func updateCartItem(item: CartItem, onSucces: @escaping () -> Void = { }, onError: @escaping (any Error) -> Void = { _ in }) {
        Task(priority: .background) { [ weak self ] in
            guard let self else { return }
            
            do {
                try await self.interactor.updateCartItem(item: item)
                /// сразу обновляем данные
                self.getCartItems(onSucces: onSucces, onError: onError)
            } catch {
                print("❌ ERROR: \(#file), \(#function): \(error.localizedDescription)")
                DispatchQueue.main.async {
                    onError(error)
                }
            }
        }
    }
    
    /// обновляем некоторые айтемы
    func updateCartItem(items: [CartItem], onSucces: @escaping () -> Void = { }, onError: @escaping (any Error) -> Void = { _ in }) {
        Task(priority: .background) { [ weak self ] in
            guard let self else { return }
            
            do {
                try await self.interactor.updateCartItem(items: items)
                /// сразу обновляем данные
                self.getCartItems(onSucces: onSucces, onError: onError)
            } catch {
                print("❌ ERROR: \(#file), \(#function): \(error.localizedDescription)")
                DispatchQueue.main.async {
                    onError(error)
                }
            }
        }
    }
    
//    MARK: - Alert Routing
    /// получаем алерт об успешном нажатии кнопки "далее"
    func getSuccesPurchaseAlert() -> UIAlertController {
        self.router.getAlert(title: LocalizatoinKey.cartSucces.value(), message: nil, buttonTitle: "OK")
    }
    
    /// алерт об ошибки
    func getErrorAlert() -> UIAlertController {
        self.router.getAlert(title: LocalizatoinKey.cartError.value(), message: nil, buttonTitle: "OK")
    }
    
    /// алерт о нажатии кнопки назад
    func getBackAlert() -> UIAlertController {
        self.router.getAlert(title: LocalizatoinKey.cartBackAlert.value(), message: nil, buttonTitle: "OK")
    }
    
    /// алерт с вопросм об оверености пользователя в удаление всех айтемов
    func getDeleteItemsAlert(onDelete: @escaping () -> Void = { }) throws -> UIAlertController {
        try self.router.getAlert(
            title: LocalizatoinKey.cartDeleteAlertTitle.value("Вопрос об удаление корзины"),
            message: nil,
            buttons: [
                .init(title: LocalizatoinKey.cartDeleteAlertNo.value("Нет"), style: .cancel),
                .init(title: LocalizatoinKey.cartDeleteAlertYes.value("Да"), style: .destructive) { _ in onDelete() }
            ]
        )
    }
    
//    MARK: - Image Loader
    /// загрузить картинку
    func loadImage(from url: String) async throws -> Data {
        try await self.interactor.loadImage(from: url)
    }
    
}
