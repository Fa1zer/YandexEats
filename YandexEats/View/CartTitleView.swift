//
//  CartTitleView.swift
//  YandexEats
//
//  Created by Artemiy Zuzin on 03.09.2024.
//

import UIKit
import SnapKit

//MARK: - Delegate
/// протокол делегата верхнего блока с заголовком и количеством блюд
protocol CartTitleViewDelegate {
    func updateCartTitleViewCount(_ view: CartTitleViewProtocol) -> Int
}

//MARK: - Cart Title View
/// протокол верхнего блока с заголовком и количеством блюд
protocol CartTitleViewProtocol: UIView {
    var delegate: CartTitleViewDelegate? { get set }
    func update()
}

final class CartTitleView: UIView, CartTitleViewProtocol {
    
//    MARK: - Properties
    /// делегат
    var delegate: (any CartTitleViewDelegate)? {
        didSet {
            self.update()
        }
    }
    /// заголовок
    private let titleLabel: UILabel = {
        let view = UILabel()
        
        view.text = LocalizatoinKey.cartTitle.value()
        view.textColor = .black
        view.font = .boldSystemFont(ofSize: 35)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    /// подзаголовок колличества блюд
    private let subtitleLabel: UILabel = {
        let view = UILabel()
        
        view.text = LocalizatoinKey.cartNoItems.value()
        view.textColor = .lightGray
        view.font = .boldSystemFont(ofSize: 16)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
//    MARK: - Life Cycle
    /// загружаем интерфейс
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setupView()
    }
    
//    MARK: - Setup View
    /// разпологаем интерфейс
    private func setupView() {
        self.backgroundColor = .white
        self.addSubview(self.titleLabel)
        self.addSubview(self.subtitleLabel)
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(40)
            make.leading.trailing.equalToSuperview().inset(15)
        }
        self.subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom)
            make.leading.trailing.equalToSuperview().inset(15)
        }
    }
    
//    MARK: - Update
    /// обновляем данные
    func update() {
        guard let count = self.delegate?.updateCartTitleViewCount(self) else { return }
        
        if count == .zero {
            self.subtitleLabel.text = LocalizatoinKey.cartNoItems.value()
        } else {
            self.subtitleLabel.text = "\(count) \(LocalizatoinKey.cartSubtitle.value(with: count))"
        }
    }
    
}
