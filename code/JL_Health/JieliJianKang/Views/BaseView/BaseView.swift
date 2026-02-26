//
//  BaseView.swift
//  JieliJianKang
//
//  Created by EzioChan on 2024/9/5.
//

import UIKit
@_exported import RxSwift
@_exported import RxCocoa
@_exported import Kingfisher
@_exported import SnapKit


class BaseView: UIView {

    public let disposeBag = DisposeBag()

    open weak var contextView: UIViewController?

    override public init(frame: CGRect) {
        super.init(frame: frame)
        initData()
        initUI()
        prepareData()
    }

    public init() {
        super.init(frame: CGRect.zero)
        initData()
        initUI()
        prepareData()
    }

    open func initUI() {

    }

    open func initData() {

    }
    
    open func prepareData() {
        
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
