//
//  ColorPaletteCell.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/03/14.
//

import UIKit

class ColorPaletteCell: UICollectionViewCell {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var paletteLabel: UILabel!
    
    @IBOutlet weak var paletteTextField: UITextField!
    @IBOutlet weak var deleteButton: UIButton!
    
    
    var colorPaletteViewModel: ColorPaletteListViewModel!
    var paletteIndex: Int!
    
    var colorPalette: ColorPalette!
    var isSelectedPalette: Bool!
    var isSettingClicked: Bool!
    
    override func layoutSubviews() {
        isSelectedPalette = colorPaletteViewModel.selectedPaletteIndex == paletteIndex
        colorPalette = colorPaletteViewModel.item(paletteIndex)
        paletteLabel.text = colorPalette.name
        paletteTextField.text = colorPalette.name
        deleteButton.layer.cornerRadius = 5
        
        if isSelectedPalette {
            self.layer.borderWidth = 3
            self.layer.cornerRadius = 10
            self.layer.borderColor = UIColor.white.cgColor
            paletteTextField.isHidden = !isSettingClicked
            deleteButton.isHidden = !isSettingClicked
        } else {
            self.layer.borderWidth = 0
            paletteTextField.isHidden = true
            deleteButton.isHidden = true

        }
        collectionView.reloadData()
    }
}

extension ColorPaletteCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colorPalette.colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorFrameCell", for: indexPath) as? ColorFrameCell else {
            return UICollectionViewCell()
        }
        cell.colorFrame.backgroundColor = colorPalette.colors[indexPath.row].uicolor
        cell.colorIndex = indexPath.row
        cell.paletteIndex = paletteIndex
        cell.isSettingClicked = isSettingClicked
        cell.colorListCollectionView = collectionView
        cell.colorPaletteViewModel = colorPaletteViewModel
        return cell
    }
}

extension ColorPaletteCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let oneSideLength = collectionView.bounds.height
        return CGSize(width: oneSideLength, height: oneSideLength)
    }
}

class ColorFrameCell: UICollectionViewCell {
    var colorIndex: Int!
    var paletteIndex: Int!
    var isSettingClicked: Bool!
    var colorListCollectionView: UICollectionView!
    var colorPaletteViewModel: ColorPaletteListViewModel!
    @IBOutlet weak var colorFrame: UIView!
    @IBOutlet weak var removeColor: UIButton!
    
    
    @IBAction func tappedRemoveColor(_ sender: Any) {
        var palette = colorPaletteViewModel.item(paletteIndex)
        let _ = palette.removeColor(index: colorIndex!)
        colorPaletteViewModel.updateSelectedPalette(palette: palette)
    }
    
    override func layoutSubviews() {
        if colorPaletteViewModel.selectedPaletteIndex == paletteIndex {
            removeColor.isHidden = !isSettingClicked
        } else {
            removeColor.isHidden = true
        }
    }
}

