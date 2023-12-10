//
//  SpecialityDoctorTableViewCell.swift
//  ressy
//
//  Created by Valeh Ismayilov on 07.12.23.
//

import UIKit

class SpecialityDoctorTableViewCell: UITableViewCell {
    
    @IBOutlet weak var doctorSpecialityCollectionView: UICollectionView!
    
    let imageNames = ["general","pediatric","otology","intestine","herbal","dentist","cardiology","more"]
    
    override func awakeFromNib() {
        super.awakeFromNib()

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0

        // Calculate the item width based on the collection view's bounds
        let itemWidth = (doctorSpecialityCollectionView.bounds.width - 3 * layout.minimumInteritemSpacing) / 4
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)

        // Set the minimum interitem spacing to achieve 4 items in a row
        layout.minimumInteritemSpacing = 0.0
        
        layout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)

        doctorSpecialityCollectionView.collectionViewLayout = layout

        doctorSpecialityCollectionView.translatesAutoresizingMaskIntoConstraints = false

        // Set up constraints
        doctorSpecialityCollectionView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        doctorSpecialityCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        doctorSpecialityCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        doctorSpecialityCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true

        doctorSpecialityCollectionView.delegate = self
        doctorSpecialityCollectionView.dataSource = self
    }

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
    }
    
}

extension SpecialityDoctorTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == doctorSpecialityCollectionView {
            return imageNames.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == doctorSpecialityCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "doctorSpecialityID", for: indexPath) as! SpecialityDoctorsCollectionViewCell
            let imageName = imageNames[indexPath.item]
            cell.imageView.image = UIImage(named: imageName)
            return cell
        }
        
        return UICollectionViewCell()
    }
}

extension SpecialityDoctorTableViewCell: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}


