//
//  AppointmentViewController.swift
//  ressy
//
//  Created by Valeh Ismayilov on 10.12.23.
//

import UIKit

class AppointmentViewController: UIViewController {
    
    @IBOutlet weak var bookButton: UIButton!
    @IBOutlet weak var timeSelectionCollectionView: UICollectionView!
    @IBOutlet weak var monthView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var previousMonthButton: UIButton!
    @IBOutlet weak var monthAndYearButton: UIButton!
    @IBOutlet weak var nextMonthButton: UIButton!
    @IBOutlet weak var datePickerView: UIPickerView!
    @IBOutlet weak var daysStackView: UIStackView!
    @IBOutlet weak var calendarCollectionView: UICollectionView!
    @IBOutlet weak var dateView: UIView!
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var specialityLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    
    var dateService = DateService()
    var selectDateMode: Bool = false
    var selectedDate: Date?
    var selectedIndexPath: IndexPath?
    
    let screenSize: CGRect = UIScreen.main.bounds
    
    var hours: [String] = ["10:00 AM","11:00 AM","12:00 AM","01:00 PM","02:00 PM","03:00 PM","04:00 PM","05:00 PM","06:00 PM"]
    var selectedHourValue: String?
    
    
    let firstColor = UIColor(red: 235/255, green: 240/255, blue: 254/255, alpha: 1)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bookButton.layer.cornerRadius = 26
        
        calendarCollectionView.dataSource = self
        calendarCollectionView.delegate = self
        
        timeSelectionCollectionView.dataSource = self
        timeSelectionCollectionView.delegate = self
        
        timeSelectionCollectionView.backgroundColor = .white
        
        dateView.backgroundColor = firstColor
        
        calendarCollectionView.backgroundColor = firstColor
        monthView.backgroundColor = firstColor
        
        dateView.layer.cornerRadius = 15
        profileView.layer.cornerRadius = 15
        
        datePickerView.dataSource = self
        datePickerView.delegate = self
        
        calendarCollectionView.setup("CalendarDayCVC", CalendarDayFlowLayout())
        
        self.title = "Book Appointment"
        let titleFont = UIFont(name: "Poppins-SemiBold", size: 18)
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: titleFont!,
            NSAttributedString.Key.foregroundColor: UIColor.black
        ]
        
        
        dateService.setMinDate(Date())
        dateService.setMaxDate(Calendar.current.date(byAdding: .year, value: 1, to: Date())!)
        
        refreshTitle()
        refreshButtons()
        changeNavBar(navigationBar:  self.navigationController!.navigationBar, to: .white,titleColor: .black)
        customizeBackButton()
    }
    
    func changeNavBar(navigationBar: UINavigationBar, to color: UIColor, titleColor: UIColor) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = color
        appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: titleColor]
        
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = navigationBar.standardAppearance
    }
    
    func customizeBackButton() {
        let backButton = UIBarButtonItem()
        backButton.title = ""
        
        let backButtonImage = UIImage(named: "backIcon")?.withRenderingMode(.alwaysOriginal)
        backButton.image = backButtonImage
        
        backButton.target = self
        backButton.action = #selector(backButtonPressed)
        
        self.navigationItem.leftBarButtonItem = backButton
    }
    
    @objc func backButtonPressed() {
        // Navigate back to the previous view controller
        self.navigationController?.popViewController(animated: true)
    }
    
    
    func reloadValues() {
        refreshTitle()
        refreshButtons()
        calendarCollectionView.reloadData()
    }
    
    func refreshTitle() {
        monthAndYearButton.setAttributedTitle(NSAttributedString(string: dateService.titleText,attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .bold)]), for: .normal)
    }
    
    func refreshButtons() {
        previousMonthButton.isHidden = dateService.isInMinDate()
        nextMonthButton.isHidden = dateService.isInMaxDate()
    }
    
    func checkSelectedDate() {
        if selectedDate?.isBefore(dateService.minDate) == true || selectedDate?.isAfter(dateService.maxDate) == true {
            selectedDate = nil
        }
    }
    @IBAction func bookAppointmentAction(_ sender: Any) {
        
    }
    
    @IBAction func nextMonthAction(_ sender: Any) {
        dateService.goNextMonth()
        reloadValues()
    }
    @IBAction func monthAndYearAction(_ sender: Any) {
        refreshTitle()
        selectDateMode = !selectDateMode
        if selectDateMode {
            if let monthIndex = dateService.monthsForPicker.firstIndex(of: dateService.date.monthName()) {
                datePickerView.selectRow(monthIndex, inComponent: 0, animated: false)
            }
            if let yearIndex = dateService.yearsForPicker.firstIndex(of: String(dateService.date.year())) {
                datePickerView.selectRow(yearIndex, inComponent: 1, animated: false)
            }
        }
        calendarCollectionView.isHidden = selectDateMode
        previousMonthButton.isHidden = selectDateMode
        nextMonthButton.isHidden = selectDateMode
        daysStackView.isHidden = selectDateMode
        datePickerView.isHidden = !selectDateMode
        if !selectDateMode { reloadValues() }
    }
    @IBAction func previousMonthAction(_ sender: Any) {
        dateService.goLastMonth()
        reloadValues()
    }
    
    @objc func button_Select(_ sender: UIButton) {
        let firstGradColor = UIColor(red: 157/255.0, green: 206/255.0, blue: 255/255.0, alpha: 1.0)
        let secondGradColor = UIColor(red: 146/255.0, green: 153/255.0, blue: 253/255.0, alpha: 1.0)
        if sender.isSelected {
            // The button is already selected, set normal state colors
            sender.backgroundColor = UIColor.white
            sender.setTitleColor(UIColor.white, for: .normal)
            sender.isSelected = false
        } else {
            // The button is not selected, set gradient background
            addGradientToView(sender, firstColor: firstGradColor, secondColor: secondGradColor)
            sender.setTitleColor(UIColor.white, for: .normal)
            sender.isSelected = true
        }
    }
}
extension AppointmentViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == calendarCollectionView { return dateService.numberOfSections }
        if collectionView == timeSelectionCollectionView {
            return 1
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == timeSelectionCollectionView {
            return hours.count
        }
        if collectionView == calendarCollectionView {
            return 7
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == calendarCollectionView {
            let calendarDate = dateService.getCalendarDate(indexPath)
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarDayCVC", for: indexPath) as! CalendarDayCVC
            cell.setup(calendarDate, selected: calendarDate.date.isEqual(selectedDate))
            return cell
        } else if collectionView == timeSelectionCollectionView {
            let firstGradColor = UIColor(red: 157/255.0, green: 206/255.0, blue: 255/255.0, alpha: 1.0)
            let secondGradColor = UIColor(red: 146/255.0, green: 153/255.0, blue: 253/255.0, alpha: 1.0)
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "selectHourID", for: indexPath) as! SelectHourCollectionViewCell
            cell.backgroundColor = UIColor.white
            cell.timeButton.isUserInteractionEnabled = true
            let selectedHour = hours[indexPath.item]
            cell.timeButton.setTitle(selectedHour, for: .normal)
            print("Selected:\(selectedHour)")
            print("Selected:\(selectedHourValue)")
            cell.backView.layer.cornerRadius = 20
            cell.layer.cornerRadius = 20
            let gradColor = [firstGradColor,secondGradColor]
            cell.backView.setGradientBorder(width: 1, colors:gradColor)
            if selectedHour == selectedHourValue {
                cell.backView.backgroundColor = UIColor.yellow  // Replace with the desired color
            } else {
                // Reset the background color when not selected
                cell.backView.backgroundColor = UIColor.clear
            }
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == calendarCollectionView {
            guard let selectedDate = dateService.daySelected(indexPath) else { return }
            self.selectedDate = selectedDate
        } else if collectionView == timeSelectionCollectionView {
            selectedHourValue = hours[indexPath.item]
            print("Selected Hour: \(selectedHourValue)")
        }
        collectionView.reloadData()
    }
}

extension AppointmentViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 2 }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return component == 0 ? dateService.monthsForPicker.count : dateService.yearsForPicker.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 { return dateService.monthsForPicker[row] }
        return dateService.yearsForPicker[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        dateService.pickerValueChanged(row, component)
        refreshTitle()
        datePickerView.reloadAllComponents()
    }
}

