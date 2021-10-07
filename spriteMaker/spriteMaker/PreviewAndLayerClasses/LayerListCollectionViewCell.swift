//
//  LayerListCollectionViewCell.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/05/06.
//

import UIKit

class LayerListCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var layerCollection: UICollectionView!
    
    var drawingCVC: DrawingCollectionViewCell!
    var layerVM: LayerListViewModel!
    var canvas: Canvas!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // add gesture
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture(_:)))
        layerCollection.addGestureRecognizer(gesture)
    }
    
    @objc func handleLongPressGesture(_ gesture: UILongPressGestureRecognizer) {
        let collectionView = layerCollection

        switch gesture.state {
        case .began:
            guard let targetIndexPath = collectionView?.indexPathForItem(at: gesture.location(in: collectionView)) else { return }
            collectionView?.beginInteractiveMovementForItem(at: targetIndexPath)
            collectionView?.cellForItem(at: targetIndexPath)?.alpha = 0.5
        case .changed:
            collectionView?.updateInteractiveMovementTargetPosition(gesture.location(in: collectionView))
        case .ended:
            collectionView?.endInteractiveMovement()
            collectionView?.reloadData()
        default:
            collectionView?.cancelInteractiveMovement()
        }
    }
    
}

extension LayerListCollectionViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return layerVM.numsOfLayer + 1  // layers + addButton
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.row {
        case layerVM.numsOfLayer:
            guard let addBtnCell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddLayerCell", for: indexPath) as? AddLayerCell else { return UICollectionViewCell() }
            addBtnCell.layerVM = layerVM
            addBtnCell.canvas = canvas
            return addBtnCell
        default:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LayerCell", for: indexPath) as? LayerCell else { return UICollectionViewCell() }
            guard let layer = layerVM.getLayer(index: indexPath.row) else { return cell }
            cell.layerImage.image = layer.renderedImage
            if (layerVM.selectedLayerIndex == indexPath.row) {
                cell.layer.borderWidth = 1
                cell.layer.borderColor = UIColor.white.cgColor
            } else {
                cell.layer.borderWidth = 0
            }
            cell.ishiddenView.isHidden = !layer.ishidden
            setViewShadow(target: cell, radius: 2, opacity: 0.5)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "LayerHeaderCell", for: indexPath) as? LayerHeaderCell else { return UICollectionReusableView() }
        header.labelNum.text = "# \(layerVM.selectedFrameIndex + 1)"
        return header
    }
}

extension LayerListCollectionViewCell: UICollectionViewDelegate {
    func updateGridData() {
        guard let layer = layerVM.selectedLayer else { return }
        let gridData = layer.gridData
        canvas.changeGrid(index: layerVM.selectedLayerIndex, gridData: gridData)
        canvas.setNeedsDisplay()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        canvas.initCanvasDrawingTools()
        
        if indexPath.row == layerVM.selectedLayerIndex {
            guard let layerOptionVC = UIStoryboard(name: "LayerOptionPopup", bundle: nil).instantiateViewController(identifier: "LayerOptionPopup") as? LayerOptionPopupViewController else { return }
            layerOptionVC.modalPresentationStyle = .overFullScreen
            layerOptionVC.layerListVM = layerVM
            
            let position = getPopupViewPosition()
            layerOptionVC.popupPositionX = position.x
            layerOptionVC.popupPositionY = position.y
            
            self.window?.rootViewController?.present(layerOptionVC, animated: false, completion: nil)
            let eyeImage = layerVM.selectedLayer!.ishidden ? "eye" : "eye.slash"
            layerOptionVC.ishiddenBtn.setImage(UIImage.init(systemName: eyeImage), for: .normal)
        } else if (indexPath.row < layerVM.numsOfLayer) {
            layerVM.selectedLayerIndex = indexPath.row
            let canvasData = layerVM.selectedLayer?.gridData ?? ""
            canvas.changeGrid(index: indexPath.row, gridData: canvasData)
            updateGridData()
        }
        layerCollection.reloadData()
    }
    
    func getPopupViewPosition() -> CGPoint {
        var pos: CGPoint
        
        pos = CGPoint(x: 0, y: 0)
        pos.x += drawingCVC.panelCollectionView.frame.minX
        pos.x += drawingCVC.previewImageToolBar.frame.minX
        pos.x += drawingCVC.previewImageToolBar.previewAndLayerCVC.frame.midX
        
        pos.y += drawingCVC.panelCollectionView.frame.minY
        pos.y += drawingCVC.previewImageToolBar.previewAndLayerCVC.frame.height + 10
        pos.y -= drawingCVC.panelCollectionView.contentOffset.y
        
        return pos
    }
}

extension LayerListCollectionViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sideLength = layerCollection.bounds.height - 5
        return CGSize(width: sideLength, height: sideLength)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let oneSideLen = layerCollection.layer.bounds.height
        return CGSize(width: oneSideLen * 0.7, height: oneSideLen)
    }
    
    // Re-order
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if (layerVM.reorderLayer(dst: destinationIndexPath.row, src: sourceIndexPath.row)) {
            drawingCVC.animatedPreviewVM.changeAnimatedPreview()
            drawingCVC.previewImageToolBar.setNeedsDisplay()
        }
    }
}

class LayerHeaderCell: UICollectionReusableView {
    @IBOutlet weak var labelNum: UILabel!
}

class LayerCell: UICollectionViewCell {
    @IBOutlet weak var layerImage: UIImageView!
    @IBOutlet weak var ishiddenView: UIView!
}

class AddLayerCell: UICollectionViewCell {
    var layerVM: LayerListViewModel!
    var canvas: Canvas!
    
    override func layoutSubviews() {
        setSideCorner(target: self, side: "all", radius: self.frame.width / 7)
        setViewShadow(target: self, radius: 2, opacity: 0.5)
    }
    
    @IBAction func addLayer(_ sender: Any) {
        guard let image = UIImage(named: "empty") else { return }
        
        canvas.initCanvasDrawingTools()
        
        layerVM.addNewLayer(layer: Layer(gridData: "", renderedImage: image, ishidden: false))
        canvas.changeGrid(index: layerVM.selectedLayerIndex, gridData: "")
        canvas.setNeedsDisplay()
        canvas.timeMachineVM.addTime()
    }
}
