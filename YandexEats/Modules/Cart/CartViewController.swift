//
//  CartViewController.swift
//  YandexEats
//
//  Created by Artemiy Zuzin on 03.09.2024.
//

import UIKit
import SnapKit

/// контроллер корзины
final class CartViewController: UIViewController {
    
    /// презентер
    private let presenter: CartPresenterProtocol
    
//    MARK: - Init
    init(presenter: CartPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    MARK: - UI Properties
    /// врезний блок с заголовком и колличеством всех блюд
    private lazy var titleView: CartTitleViewProtocol = {
        let view = CartTitleView()
        
        view.layer.zPosition = 1
        view.backgroundColor = .white
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    /// таблица с айтемами
    private lazy var itemsTableView: UITableView = {
        let view = UITableView(frame: .zero, style: .plain)
        
        view.backgroundColor = .clear
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.delegate = self
        view.dataSource = self
        view.register(ItemTableViewCell.self, forCellReuseIdentifier: ItemTableViewCell.id)
        view.contentInsetAdjustmentBehavior = .never
        view.contentInset = .init(top: .zero, left: .zero, bottom: 8, right: .zero)
        view.separatorColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    /// нижний блок с кнопкой "далее"
    private lazy var bottomButton: CartBottomButtonProtocol = {
        let view = CartBottomButton()
        
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    /// просто белай вьюшка для закрытия статус бара
    private let statusBarBackgroundView: UIView = {
        let view = UIView()
        
        view.layer.zPosition = .zero
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
//    MARK: - Life Cycle
    /// загружаем интерфейс
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupViews()
    }
    
    /// обновляем данные
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter.getCartItems { [ weak self ] in
            guard let self else { return }
            if self.presenter.items.isEmpty {
                /// скрываем некоторые вью, елси у нас нету айтемов
                self.navigationItem.rightBarButtonItem?.isEnabled = false
                self.itemsTableView.isHidden = true
                self.bottomButton.isHidden = true
            } else {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                self.itemsTableView.isHidden = false
                self.bottomButton.isHidden = false
            }
            /// обновляем вьюхи с данными
            self.titleView.update()
            UIView.performWithoutAnimation {
                self.itemsTableView.reloadData()
            }
            self.bottomButton.update()
        } onError: { [ weak self ] _ in
            guard let alert = self?.presenter.getErrorAlert() else { return }
            /// презентуем ошибку
            self?.present(alert, animated: true)
        }
    }
    
//    MARK: - Setup View
    /// располагаем весь интерфейс
    private func setupViews() {
        self.view.backgroundColor = #colorLiteral(red: 0.9688869119, green: 0.96553725, blue: 0.9593732953, alpha: 1)
        self.setUpNavigationBar()
        self.setUpCartTitleView()
        self.setUpItemsTableView()
        self.setUpBottomButton()
        self.setupStatusBarBackgroundView()
    }
    
    /// располагаем статус бар
    private func setupStatusBarBackgroundView() {
        self.view.addSubview(self.statusBarBackgroundView)
        self.statusBarBackgroundView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.bottom.equalTo(self.itemsTableView.snp.top)
        }
    }
    
    /// располагаем нижний блок с кнопкой "далее"
    private func setUpBottomButton() {
        self.view.addSubview(self.bottomButton)
        self.bottomButton.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(self.view)
            make.top.equalTo(self.itemsTableView.snp.bottom)
        }
    }
    
    /// располагаем таблицу с айтемами
    private func setUpItemsTableView() {
        self.view.addSubview(self.itemsTableView)
        self.itemsTableView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide).inset(100)
            make.leading.trailing.equalToSuperview()
        }
    }
    
    /// располагаем врехний блок с заголовком и количеством блюд
    private func setUpCartTitleView() {
        self.view.addSubview(self.titleView)
        self.titleView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
    
    /// настрайваем бар навигации
    private func setUpNavigationBar() {
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.title = nil
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationController?.navigationBar.backgroundColor = .white
        self.navigationItem.leftBarButtonItem = .init(
            image: .init(systemName: "arrow.left")!.withRenderingMode(.alwaysTemplate),
            style: .done,
            target: self,
            action: #selector(self.didTapBackButton)
        )
        self.navigationItem.rightBarButtonItem = .init(
            image: .init(systemName: "trash")!.withRenderingMode(.alwaysTemplate),
            style: .done,
            target: self,
            action: #selector(self.didTapDeleteButton)
        )
        self.navigationItem.leftBarButtonItem?.tintColor = .black
        self.navigationItem.rightBarButtonItem?.tintColor = .black
    }
    
//    MARK: - Actions
    /// обработка нажатия на кнопку назад
    @objc private func didTapBackButton() {
        self.present(self.presenter.getBackAlert(), animated: true)
    }
    
    /// обработа нажатия на кнопку удалить
    @objc private func didTapDeleteButton() {
        guard !self.presenter.items.isEmpty else { return }
        
        /// вибро-отклик
        HapticFeedbackGenerator.heavy.prepare()
        
        do {
            /// алерт где спрашивают пользователя в уверености совершить удаление
            let alert = try self.presenter.getDeleteItemsAlert { [ weak self ] in
                /// удаляем
                self?.presenter.deleteCart {
                    /// скрываем некоторые вью и обновляем данные
                    self?.titleView.update()
                    UIView.performWithoutAnimation {
                        self?.itemsTableView.reloadData()
                    }
                    self?.bottomButton.update()
                    self?.navigationItem.rightBarButtonItem?.isEnabled = false
                    self?.itemsTableView.isHidden = true
                    self?.bottomButton.isHidden = true
                } onError: { _ in
                    guard let controller = self?.presenter.getErrorAlert() else { return }
                    
                    /// алерт об ошибке
                    self?.present(controller, animated: true)
                }
            }
            
            self.present(alert, animated: true)
        } catch {
            print("❌ ERROR: \(#file), \(#function): \(error.localizedDescription)")
            /// алерт об ошибке
            self.present(self.presenter.getErrorAlert(), animated: true)
        }
    }
    
}

//MARK: Cart Title View Delegate Extension
extension CartViewController: CartTitleViewDelegate {
    /// колличесство блюд
    func updateCartTitleViewCount(_ view: any CartTitleViewProtocol) -> Int {
        self.presenter.items.count
    }
}

//MARK: Table View Data Source Extension
extension CartViewController: UITableViewDataSource {
    
    /// колличество айтемов
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.presenter.items.count
    }
    
    /// создаем ячейку айтема
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ItemTableViewCell.id,
            for: indexPath
        ) as? ItemTableViewCellProtocol else {
            return .init()
        }
        
        cell.delegate = self
        cell.isLastItem = (indexPath.row == (self.presenter.items.count - 1))
        cell.item = self.presenter.items[indexPath.row]
        
        return cell
    }
    
}

//MARK: Table View Delegate Extension
extension CartViewController: UITableViewDelegate {
    /// высота ячейки автоматическая
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
}

//MARK: Item Table View Cell Delegate Extension
extension CartViewController: ItemTableViewCellDelegate {
    
    /// обработка изменения колличества продукта
    func didTapChangeButton(_ view: any ItemTableViewCellProtocol, count: Int) {
        guard let item = view.item else { return }
        
        self.presenter.updateCartItem(
            item: .init(id: item.id, name: item.name, count: count, price: item.price, currency: item.currency, imageUrl: item.imageUrl)
        ) { [ weak self ] in
            /// елсли равно 0, удаляем айтем
            if count == .zero {
                self?.titleView.update()
                UIView.performWithoutAnimation {
                    self?.itemsTableView.reloadData()
                }
                self?.bottomButton.update()
                
                guard let self else { return }
                if self.presenter.items.isEmpty {
                    /// скрываем некоторые вью
                    self.navigationItem.rightBarButtonItem?.isEnabled = false
                    self.itemsTableView.isHidden = true
                    self.bottomButton.isHidden = true
                } else {
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                    self.itemsTableView.isHidden = false
                    self.bottomButton.isHidden = false
                }
            } else {
                /// если не равно 0, просто обновляем
                guard let cells = self?.itemsTableView.visibleCells as? [ItemTableViewCellProtocol],
                      let index = cells.firstIndex(where: { $0.item?.id == item.id }) else { return }
                
                UIView.performWithoutAnimation {
                    self?.itemsTableView.reloadRows(at: [.init(row: index, section: .zero)], with: .none)
                }
                self?.bottomButton.update()
            }
        } onError: { [ weak self ] error in
            guard let alert = self?.presenter.getErrorAlert() else { return }
            
            /// презентуем ошибку
            self?.present(alert, animated: true)
        }
    }
    
    /// загружаем картинку
    func loadImage(_ view: any ItemTableViewCellProtocol, item: CartItem) async -> Data? {
        do {
            return try await self.presenter.loadImage(from: item.imageUrl)
        } catch {
            print("❌ ERROR: \(#file), \(#function): \(error.localizedDescription)")
            return nil
        }
    }
    
}

//MARK: - Cart Bottom Button Delegate
extension CartViewController: CartBottomButtonDelegate {
    
    /// обновляем информацию в кнопке "далее"
    func updateCartBottomButtonDelegate(_ view: any CartBottomButtonProtocol) -> (price: Int, currency: String) {
        (self.presenter.totalPrice, self.presenter.currency ?? .init())
    }
    
    /// обработка нажатия на кнопку "далее"
    func didTapButton(_ view: any CartBottomButtonProtocol) {
        self.present(self.presenter.getSuccesPurchaseAlert(), animated: true)
    }
    
}
