//
//  ItemTableViewCell.swift
//  YandexEats
//
//  Created by Artemiy Zuzin on 03.09.2024.
//

import UIKit
import SnapKit

//MARK: - Delegate
/// протокол делегата ячейки айтема
protocol ItemTableViewCellDelegate {
    func didTapChangeButton(_ view: ItemTableViewCellProtocol, count: Int)
    func loadImage(_ view: ItemTableViewCellProtocol, item: CartItem) async -> Data?
}

//MARK: - Item Table View Cell
/// протокол ячейки айтема
protocol ItemTableViewCellProtocol: UITableViewCell {
    var item: CartItem? { get set }
    var delegate: ItemTableViewCellDelegate? { get set }
    var isLastItem: Bool { get set }
    
    func update()
}

/// ячейка айтема
final class ItemTableViewCell: UITableViewCell, ItemTableViewCellProtocol {
    
//    MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    MARK: - Properties
    /// id для переиспользования ячеек
    static let id = String(describing: ItemTableViewCell.self)
    /// показывает последний ли это элемент, нужен для обновления интерфейса
    var isLastItem = false {
        didSet {
            self.lastItemHandler()
        }
    }
    /// айетм
    var item: CartItem? {
        didSet {
            self.update()
        }
    }
    /// делегат
    var delegate: (any ItemTableViewCellDelegate)? {
        didSet {
            self.update()
        }
    }
    /// последний url картинки, нужен, что бы не загружать картинку лишний раз
    private var lastImageURL: String?
    /// картинка айтема
    private let itemImageView: UIImageView = {
        let view = UIImageView()
        
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    /// стэк с описаниес для айтема
    private let textStackView: UIStackView = {
        let view = UIStackView()
        
        view.axis = .vertical
        view.spacing = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    /// заголовок айтема
    private let titleLabel: UILabel = {
        let view = UILabel()
        
        view.font = .systemFont(ofSize: 15)
        view.textColor = .black
        view.numberOfLines = 2
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    /// общая цена айтема, с учетом колличества
    private let priceLabel: UILabel = {
        let view = UILabel()
        
        view.font = .systemFont(ofSize: 16)
        view.textColor = .black
        view.numberOfLines = 1
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    /// блок с выбором колличества продукта
    private lazy var countSwitchView: CountSwitchViewProtocol = {
        let view = CountSwitchView()
        
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    /// разделитель ячеек
    private let separatorView: UIView = {
        let view = UIView()
        
        view.backgroundColor = #colorLiteral(red: 0.9688869119, green: 0.96553725, blue: 0.9593732953, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
//    MARK: - Setup View
    /// разпологает весь интерфейс
    func setupView() {
        self.backgroundColor = .clear
        self.selectionStyle = .none
        self.contentView.backgroundColor = .white
        self.contentView.addSubview(self.itemImageView)
        self.contentView.addSubview(self.textStackView)
        self.textStackView.addArrangedSubview(self.titleLabel)
        self.textStackView.addArrangedSubview(self.priceLabel)
        self.contentView.addSubview(self.countSwitchView)
        self.contentView.addSubview(self.separatorView)
        self.itemImageView.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview().inset(16)
            make.width.height.equalTo(60)
        }
        self.textStackView.snp.makeConstraints { make in
            make.leading.equalTo(self.itemImageView.snp.trailing).inset(-8)
            make.centerY.equalTo(self.itemImageView)
            make.trailing.equalTo(self.countSwitchView.snp.leading).inset(-16)
        }
        self.countSwitchView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.width.equalTo(100)
            make.height.equalTo(30)
        }
        self.lastItemHandler()
    }
    
//    MARK: - Update
    /// обновляет все данные, кромме картинки
    func update() {
        guard let item else { return }
        
        self.titleLabel.text = item.name
        self.priceLabel.text = "\(item.price * item.count) \(item.currency)"
        self.countSwitchView.update()
        self.setupImage()
    }
    
//    MARK: - Setup Image
    /// обновляет картинку
    func setupImage() {
        Task(priority: .background) { [ weak self ] in
            guard let self, let item, self.lastImageURL != item.imageUrl else { return }
            if let data = await self.delegate?.loadImage(self, item: item) {
                DispatchQueue.main.async {
                    self.itemImageView.contentMode = .scaleAspectFill
                    self.itemImageView.image = .init(data: data)
                }
            } else {
                DispatchQueue.main.async {
                    self.itemImageView.image = .init(systemName: "questionmark")
                    self.itemImageView.contentMode = .scaleToFill
                    self.itemImageView.tintColor = #colorLiteral(red: 0.9688869119, green: 0.96553725, blue: 0.9593732953, alpha: 1)
                }
            }
            
            DispatchQueue.main.async {
                self.lastImageURL = item.imageUrl
            }
        }
    }
    
//    MARK: - Last Item Handler
    func lastItemHandler() {
        /// обработкчик формы ячеки
        self.contentView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        self.contentView.clipsToBounds = true
        self.contentView.layer.masksToBounds = true
        self.contentView.layer.cornerRadius = self.isLastItem ? 24: .zero
        self.separatorView.snp.removeConstraints()
        
        if !self.isLastItem {
            self.separatorView.snp.makeConstraints { make in
                make.height.equalTo(1.5)
                make.bottom.trailing.equalToSuperview()
                make.leading.equalTo(self.textStackView)
            }
        } else {
            self.separatorView.snp.makeConstraints { make in
                make.height.equalTo(1.5)
                make.bottom.leading.trailing.equalToSuperview()
            }
        }
    }
    
}

//MARK: - Extensions
extension ItemTableViewCell: CountSwitchViewDelegate {
    
    func updateCountSwitchView(_ view: CountSwitchViewProtocol) -> Int {
        self.item?.count ?? .zero
    }
    
    func didTapChangeButton(_ view: any CountSwitchViewProtocol, count: Int) {
        self.delegate?.didTapChangeButton(self, count: count)
    }
    
}
