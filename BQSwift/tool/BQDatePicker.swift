// *******************************************
//  File Name:      BQTimePicker.swift       
//  Author:         MrBai
//  Created Date:   2021/6/3 9:53 AM
//    
//  Copyright © 2021 ___ORGANIZATIONNAME___
//  All rights reserved
// *******************************************
    

import UIKit

struct DatePickerOptions: OptionSet {
    let rawValue: UInt
    static let year = DatePickerOptions(rawValue: 1 << 1)
    static let month = DatePickerOptions(rawValue: 1 << 2)
    static let day = DatePickerOptions(rawValue: 1 << 3)
    static let hour = DatePickerOptions(rawValue: 1 << 4)
    static let min = DatePickerOptions(rawValue: 1 << 5)
    static let second = DatePickerOptions(rawValue: 1 << 6)
    
    public func convenToArr() -> [DatePickerOptions] {
        let arr:[DatePickerOptions] = [.year, .month, .day, .hour, .min, .second]
        var outArr = [DatePickerOptions]()
        for type in arr {
            if self.contains(type) {
                outArr.append(type)
            }
        }
        return outArr
    }
}

protocol BQDatePickerDelegate: NSObjectProtocol {
    func datePickerCancel(_ picker: BQDatePicker)
    func datePickerSelect(_ picker: BQDatePicker, model: DateComponents)
}

extension BQDatePickerDelegate {
    func datePickerCancel(_ picker: BQDatePicker) {}
}


class BQDatePicker: UIView {

    //MARK: - *** Ivars
    public var delegate: BQDatePickerDelegate?
    
    public var options: DatePickerOptions {
        didSet {
            numopt = options.convenToArr()
        }
    }
    
    public var currentTitle: String {
        didSet {
            if let lab = centerLab {
                lab.text = currentTitle
            }
        }
    }
    
    private var numopt = [DatePickerOptions]()
    
    private var bgView: UIView!
    private var animationView: UIView!
    private var pickView: UIPickerView!
    private var backBtn: UIButton!
    private var sureBtn: UIButton!
    private var centerLab: UILabel!
    private var dateModel: DateComponents = Date().components()
    private var startYear: Int = 1970
    
    //MARK: - *** Public method

    /// 配置时间选择器
    /// - Parameters:
    ///   - disTitle: 展示标题
    ///   - options: 展示内容
    ///   - supV: 父视图，未传入父视图，则会加载到KeyWindow上，需要自行控制remove
    public static func config(disTitle: String = "请选择时间", options: DatePickerOptions = [.year , .month, .day], supV: UIView? = nil) -> BQDatePicker {
        
        let supView: UIView! = supV ?? UIApplication.shared.keyWindow
        
        let pickerV = BQDatePicker(frame: supView.bounds, title: disTitle, opt: options)
        supView.addSubview(pickerV)
        
        return pickerV
    }
    
    /// 展示
    public func show(date: Date = Date()) {
        changeDate(date: date)
        isHidden = false
        UIView.animate(withDuration: 0.25) { [weak self] in
            self!.bgView.alpha = 1
            self!.animationView.top = self!.size.height - self!.animationView.size.height
        }
        
    }
    
    /// 隐藏
    public func hide() {
        UIView.animate(withDuration: 0.25) { [weak self] in
            self!.bgView.alpha = 0
            self!.animationView.top = self!.size.height
        } completion: { result in
            self.isHidden = true
        }
    }
    
    /// 改变当前展示时间
    public func changeDate(date: Date) {
        dateModel = date.components()
        startYear = dateModel.year! - 30
        pickView.reloadAllComponents()
        
        if pickView.showsSelectionIndicator {
            for subV in pickView.subviews {
                if (subV.frame.height <= 1) {
                    subV.isHidden = false
                    subV.backgroundColor = .gray
                }
            }
            pickView.showsSelectionIndicator = false
        }
        
        showCurrentTime()
    }
    
    //MARK: - *** Life cycle
    
    private init(frame: CGRect, title: String, opt: DatePickerOptions) {
        options = opt
        currentTitle = title
        super.init(frame: frame)
        configUI()
        isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - *** NetWork method

    //MARK: - *** Event Action
    @objc private func backBtnClick() {
        BQLog("返回")
        if let delegate = delegate {
            delegate.datePickerCancel(self)
        }
        hide()
    }
    
    @objc private func sureBtnClick() {
        BQLog("确定")
        hide()
        
        if let delegate = delegate {
            delegate.datePickerSelect(self, model: dateModel)
        }
    }

    //MARK: - *** Delegate

    //MARK: - *** Instance method
    private func showCurrentTime() {
        for (index, type) in numopt.enumerated() {
            var row = 0
            switch type {
            case .year:
                row = dateModel.year! - startYear
            case .month:
                row = dateModel.month! - 1
            case .day:
                row = dateModel.day! - 1
            case .hour:
                row = dateModel.hour!
            case .min:
                row = dateModel.minute!
            case .second:
                row = dateModel.second!
            default:
                row = 0
            }
            if row > 0 {
                pickView.selectRow(row, inComponent: index, animated: false)
            }
        }
    }

    //MARK: - *** UI method

    private func configUI() {
        
        // 背景色
        bgView = UIView(frame: self.bounds)
        bgView.alpha = 0
        bgView.backgroundColor = UIColor.init(white: 0, alpha: 0.3)
        addSubview(bgView)
        
        // 模拟弹窗
        animationView = UIView(frame: CGRect(x: 0, y: self.size.height, width: self.size.width, height: 224))
        animationView.backgroundColor = .white
        addSubview(animationView)
        
        // 选择器
        pickView = UIPickerView(frame: CGRect(x: 0, y: 44, width: animationView.size.width, height: animationView.size.height - 44))
        pickView.delegate = self
        pickView.dataSource = self
        pickView.showsSelectionIndicator = true
        let lineLayer = CALayer.lineLayer(frame: CGRect(x: 0, y: 0, width: pickView.size.width, height: 1))
        pickView.layer.addSublayer(lineLayer)
        animationView.addSubview(pickView)
        
        // 返回按钮
        backBtn = UIButton(type: .custom)
        backBtn.setTitle("返回", for: .normal)
        backBtn.setTitleColor(.black, for: .normal)
        backBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        backBtn.frame = CGRect(x: 12, y: 0, width: 44, height: 44)
        backBtn.addTarget(self, action: #selector(backBtnClick), for: .touchUpInside)
        animationView.addSubview(backBtn)
        
        //标题
        centerLab = UILabel(frame: CGRect(x: backBtn.right, y: 0, width: animationView.size.width - 120, height: 44), font: UIFont.systemFont(ofSize: 16), text: currentTitle, textColor: .black, alignment: .center)
        animationView.addSubview(centerLab)
        
        // 确定按钮
        sureBtn = UIButton(type: .custom)
        sureBtn.setTitle("确定", for: .normal)
        sureBtn.setTitleColor(.black, for: .normal)
        sureBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        sureBtn.frame = CGRect(x: centerLab.right, y: 0, width: 44, height: 44)
        sureBtn.addTarget(self, action: #selector(sureBtnClick), for: .touchUpInside)
        animationView.addSubview(sureBtn)
        
    }
    
}

extension BQDatePicker: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return numopt.count
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {

        let type = numopt[component]
        switch type {
        case .year:
            return 60
        case .month:
            return 12
        case .day:
            return loadMonthRows()
        case .hour:
            return 24
        case .min:
            return 60
        case .second:
            return 60
        default:
            break
        }
        return 0
    }
    
    fileprivate func loadMonthRows() -> Int {
        switch dateModel.month {
        case 4,6,9,11:
            return 30
        case 2:
            let year = dateModel.year!
            if ((year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)) {
                return 29;
            }
            return 28;
        default:
            return 31
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let type = numopt[component]
        switch type {
        case .year:
            return String(startYear + row) + "年"
        case .month:
            return String(row + 1) + "月"
        case .day:
            return String(row + 1) + "日"
        case .hour:
            return String(row) + "时"
        case .min:
            return String(row) + "分"
        case .second:
            return String(row) + "秒"
        default:
            break
        }
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let type = numopt[component]
        switch type {
        case .year:
            dateModel.year = startYear + row
            pickerView.reloadAllComponents()
            break
        case .month:
            dateModel.month = row + 1
            pickerView.reloadAllComponents()
            break
        case .day:
            dateModel.day = row + 1
            break
        case .hour:
            dateModel.hour = row
            break
        case .min:
            dateModel.minute = row
            break
        case .second:
            dateModel.second = row
            break
        default:
            break
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel = view as? UILabel;

        if (pickerLabel == nil)
        {
            let lab = UILabel()
            lab.frame = CGRect(x: 0, y: 0, width: Int(pickView.size.width) / numopt.count, height: 30)
            lab.font = UIFont.systemFont(ofSize: 15)
            lab.textAlignment = .center
            pickerLabel = lab
        }
        pickerLabel?.text = self.pickerView(pickView, titleForRow: row, forComponent: component)
        return pickerLabel!;
    }
}
