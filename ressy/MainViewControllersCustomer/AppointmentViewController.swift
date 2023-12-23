//
//  AppointmentViewController.swift
//  ressy
//
//  Created by Valeh Ismayilov on 10.12.23.
//

import UIKit
import SwiftKeychainWrapper

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
    
    var patientImage:UIImage?

    var dateService = DateService()
    var selectDateMode: Bool = false
    
    var selectedDateWithoutTime: Date?
    var formattedSelectedDate: String?
    var selectedDate: Date?
    var selectedHour:String?
    var selectedDoctor:Doctor?
    var patientName:String?
    var patientAge:String?
    var patientGender:String?
    var patientProblem:String?
    
    var hours: [String] = ["10:00 AM","11:00 AM","12:00 PM","01:00 PM","02:00 PM","03:00 PM","04:00 PM","05:00 PM","06:00 PM"]
    
    let firstColor = UIColor(red: 235/255, green: 240/255, blue: 254/255, alpha: 1)
    let firstGradColor = UIColor(red: 157/255.0, green: 206/255.0, blue: 255/255.0, alpha: 1.0)
    let secondGradColor = UIColor(red: 146/255.0, green: 153/255.0, blue: 253/255.0, alpha: 1.0)
    let textColor = UIColor(red: 163/255.0, green: 194/255.0, blue: 249/255.0, alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
        setupNavigationBar()
        setupDateService()
        setupDoctorInfo()
    }
    
    func setupUI() {
        bookButton.layer.cornerRadius = 26
        dateView.backgroundColor = firstColor
        calendarCollectionView.backgroundColor = firstColor
        monthView.backgroundColor = firstColor
        dateView.layer.cornerRadius = 15
        profileView.layer.cornerRadius = 15
        timeSelectionCollectionView.backgroundColor = .white
    }
    
    func setupCollectionView() {
        calendarCollectionView.dataSource = self
        calendarCollectionView.delegate = self
        timeSelectionCollectionView.dataSource = self
        timeSelectionCollectionView.delegate = self
        datePickerView.dataSource = self
        datePickerView.delegate = self
        calendarCollectionView.setup("CalendarDayCVC", CalendarDayFlowLayout())
    }
    
    func setupNavigationBar() {
        self.title = "Book Appointment"
        let titleFont = UIFont(name: "Poppins-SemiBold", size: 18)
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: titleFont!,
            NSAttributedString.Key.foregroundColor: UIColor.black
        ]
        changeNavBar(navigationBar:  self.navigationController!.navigationBar, to: .white,titleColor: .black)
        customizeBackButton()
    }
    
    func setupDateService() {
        dateService.setMinDate(Date())
        dateService.setMaxDate(Calendar.current.date(byAdding: .year, value: 1, to: Date())!)
        refreshTitle()
        refreshButtons()
    }
    
    func setupDoctorInfo() {
        let name = "\(selectedDoctor?.firstName ?? "") \(selectedDoctor?.lastName ?? "")"
        nameLabel.text = name
        specialityLabel.text = selectedDoctor?.profession
        profileImage.image = selectedDoctor?.image
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
        profileImage.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        profileImage.layer.masksToBounds = true
        profileImage.contentMode = .scaleAspectFill
    }
    
    
    func changeNavBar(navigationBar: UINavigationBar, to color: UIColor, titleColor: UIColor) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = color
        appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: titleColor]
        
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = navigationBar.standardAppearance
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
        scheduleAppointment()
    }
    
    func scheduleAppointment() {
        guard let url = URL(string: "http://ressy-appointment-service-1978464186.eu-west-1.elb.amazonaws.com/appointment/schedule") else {
            print("Invalid URL")
            return
        }
        
        guard let patName = patientName, let patAge = patientAge, let patGender = patientGender, let patProblem = patientProblem else {
            return
        }
        
        guard let jwtToken = KeychainWrapper.standard.string(forKey: "jwtToken") else {
            print("JWT token not found in Keychain")
            return
        }
        
        let appointmentData: [String: Any] = [
            "doctorName": "\(selectedDoctor?.firstName ?? "") \(selectedDoctor?.lastName ?? "")",
            "doctorProfession": selectedDoctor?.profession ?? "",
            "doctorEmail":selectedDoctor?.email ?? "",
            "patientName": patName,
            "patientAge": patAge,
            "patientGender": patGender,
            "patientProblem": patProblem,
            "appointmentDate": formatDate(),
            "appointmentTime": formatTime(),
            "doctorPhoto": selectedDoctor?.base64 ?? ""
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: appointmentData)
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = jsonData
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("Bearer \(jwtToken)", forHTTPHeaderField: "Authorization")
            
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                } else if let data = data {
                    let responseString = String(data: data, encoding: .utf8)
                    print("Response: \(responseString ?? "")")
                    DispatchQueue.main.async {
                        if let navigationController = self.navigationController {
                            navigationController.popToRootViewController(animated: true)
                        } else {
                            self.dismiss(animated: true, completion: nil)
                        }
                        self.showSuccess(message: "Appointment scheduled successfully.")
                    }
                }
            }
            
            task.resume()
        } catch {
            print("Error encoding JSON: \(error.localizedDescription)")
        }
    }
    
    private func formatDate() -> String {
        guard let selectedDate = selectedDate else {
            return "Selected date or hour is nil"
        }
        
        return "\(formattedSelectedDate!)"
    }
    
    private func formatTime() -> String {
        guard let selectedHour = selectedHour else {
            return "Selected date or hour is nil"
        }
        
        let hourFormatter = DateFormatter()
        hourFormatter.dateFormat = "hh:mm a"
        
        if let date = hourFormatter.date(from: selectedHour) {
            hourFormatter.dateFormat = "HH:mm:ss"
            let formattedHour = hourFormatter.string(from: date)
            return "\(formattedHour)"
        } else {
            print("Error formatting hour")
            return "Error"
        }
    }
    
    private func formatHour() -> String {
        guard let selectedHour = selectedHour else {
            return "Selected hour is nil"
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        
        if let date = dateFormatter.date(from: selectedHour) {
            dateFormatter.dateFormat = "HH:mm"
            return dateFormatter.string(from: date)
        } else {
            print("Error formatting hour")
            return "Error"
        }
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
    func deselectCell(_ cell: SelectHourCollectionViewCell) {
        selectedHour = nil
        
        if let gradientLayer = cell.backView.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.removeFromSuperlayer()
        }
        cell.backView.backgroundColor = .white
        cell.timeLabel.textColor = textColor
        cell.isSelected = false
    }
    func selectCell(_ cell: SelectHourCollectionViewCell) {
        addGradientToView(cell.backView, firstColor: firstGradColor, secondColor: secondGradColor)
        cell.timeLabel.textColor = .white
        cell.isSelected = true
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
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "selectHourID", for: indexPath) as! SelectHourCollectionViewCell
            cell.backgroundColor = UIColor.white
            let selectedHour = hours[indexPath.item]
            cell.timeLabel.text = selectedHour
            cell.backView.layer.cornerRadius = 20
            cell.layer.cornerRadius = 20
            let gradColor = [firstGradColor,secondGradColor]
            cell.backView.setGradientBorder(width: 1, colors:gradColor)
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == calendarCollectionView {
            guard let selectedDate = dateService.daySelected(indexPath) else { return }
            self.selectedDate = selectedDate
            self.selectedDateWithoutTime = Calendar.current.startOfDay(for: selectedDate)
            
            if let selectedDateWithoutTime = selectedDateWithoutTime {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let formattedDate = dateFormatter.string(from: selectedDateWithoutTime)
                formattedSelectedDate = formattedDate
            } else {
                print("No date selected")
            }
            reloadValues()
        } else if collectionView == timeSelectionCollectionView {
            for selectedItemIndexPath in timeSelectionCollectionView.indexPathsForSelectedItems ?? [] {
                if selectedItemIndexPath != indexPath {
                    if let cell = collectionView.cellForItem(at: selectedItemIndexPath) as? SelectHourCollectionViewCell {
                        deselectCell(cell)
                    }
                }
            }
            if let cell = collectionView.cellForItem(at: indexPath) as? SelectHourCollectionViewCell {
                selectedHour = hours[indexPath.item]
                selectCell(cell)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if collectionView == timeSelectionCollectionView {
            if let cell = collectionView.cellForItem(at: indexPath) as? SelectHourCollectionViewCell {
                deselectCell(cell)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if collectionView == timeSelectionCollectionView {
            if collectionView.cellForItem(at: indexPath)?.isSelected ?? false {
                collectionView.deselectItem(at: indexPath, animated: true)
                if let cell = collectionView.cellForItem(at: indexPath) as? SelectHourCollectionViewCell {
                    deselectCell(cell)
                }
                return false
            }
        }
        return true
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

