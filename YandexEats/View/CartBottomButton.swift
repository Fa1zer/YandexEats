//
//  CartBottomButton.swift
//  YandexEats
//
//  Created by Artemiy Zuzin on 03.09.2024.
//

import UIKit
import SnapKit

//MARK: - Delegate
/// протокол делегата блока с кнопкой "далее"
protocol CartBottomButtonDelegate {
    func updateCartBottomButtonDelegate(_ view: CartBottomButtonProtocol) -> (price: Int, currency: String)
    func didTapButton(_ view: CartBottomButtonProtocol)
}

//MARK: - Cart Bottom Button
/// протокол блока с кнопкой "далее"
protocol CartBottomButtonProtocol: UIView {
    var delegate: CartBottomButtonDelegate? { get set }
    func update()
}

/// блок с кнопкой "далее"
final class CartBottomButton: UIView, CartBottomButtonProtocol {
    
//    MARK: - Properties
    /// делегат
    var delegate: (any CartBottomButtonDelegate)? {
        didSet {
            self.update()
        }
    }
    /// кнопка "далее"
    private lazy var nextButton: UIButton = {
        let view = UIButton()
        
        view.backgroundColor = .systemYellow
        view.setTitle(LocalizatoinKey.cartButtonTitle.value(), for: .normal)
        view.titleLabel?.font = .boldSystemFont(ofSize: 18)
        view.setTitleColor(.black, for: .normal)
        view.clipsToBounds = true
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 16
        view.addTarget(self, action: #selector(self.didTapNextButton), for: .touchUpInside)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    /// лейбл с общей ценой
    private let priceLabel: UILabel = {
        let view = UILabel()
        
        view.font = .boldSystemFont(ofSize: 18)
        view.textColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
//    MARK: - Life Cycle
    /// загрузка интерфейса
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setupView()
    }
    
//    MARK: - Setup View
    /// разсполагает весь интерфейс
    func setupView() {
        self.backgroundColor = .white
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.clipsToBounds = true
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 24
        self.layer.shadowColor = UIColor(red: 0.5, green: 0.5, blue: 0.65, alpha: 0.9).cgColor
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = 20
        self.layer.shadowOffset = CGSize(width: 0, height: -10)
        self.addSubview(self.nextButton)
        self.nextButton.addSubview(self.priceLabel)
        self.nextButton.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview().inset(8)
            make.bottom.equalToSuperview().inset(24)
            make.height.equalTo(60)
        }
        self.priceLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
    }
    
//    MARK: - Update
    /// обновляет данные
    func update() {
        guard let (price, currency) = self.delegate?.updateCartBottomButtonDelegate(self) else { return }
        
        self.priceLabel.text = "\(price) \(currency)"
    }
    
//    MARK: - Actions
    /// обработка нажтия на кнопку "далее"
    @objc private func didTapNextButton() {
        self.delegate?.didTapButton(self)
    }
    
}
