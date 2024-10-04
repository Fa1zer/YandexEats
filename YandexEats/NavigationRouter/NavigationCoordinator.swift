//
//  NavigationRouter.swift
//  YandexEats
//
//  Created by Artemiy Zuzin on 03.09.2024.
//

import UIKit

//MARK: - Navigation Core
/// протокол главного координатора
protocol NavigationCore {
    var navigationController: UINavigationController { get }
    
    func start() -> UIViewController
    func goTo(_ viewController: UIViewController, isAnimated: Bool)
}

//MARK: - Navigation Router
/// главный координатор в приложение
final class NavigationCoordinator: NavigationCore {
    
    /// главный контроллер навигации
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    static let shared = NavigationCoordinator(navigationController: .init())
    
//    MARK: - Start
    /// вызываеться для старта приложения
    func start() -> UIViewController {
        self.navigationController.pushViewController(self.getCart(), animated: false)
        
        return self.navigationController
    }
    
//    MARK: - Go To
    /// пушит любой контроллер на выбор
    func goTo(_ viewController: UIViewController, isAnimated: Bool = true) {
        self.navigationController.pushViewController(viewController, animated: isAnimated)
    }
    
//    MARK: - Cart
    /// выдает собранный модуль корзины
    func getCart() -> UIViewController {
        CartViewController(
            presenter: CartPresenter(
                router: CartRouter(alertCoordinator: AlertCoordinator.shared, navigationCoordinator: self),
                interactor: CartInteractor(
                    cartManager: CartManagerMock(storage: CartItemsStorageMock.shared),
                    imageLoader: ImageLoaderMock.shared
                )
            )
        )
    }
    
    /// переходит к собранному модулю корзины
    func goToCart(isAnimated: Bool = true) {
        self.goTo(self.getCart(), isAnimated: isAnimated)
    }
    
}
