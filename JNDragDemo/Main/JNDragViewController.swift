//
//  JNDragViewController.swift
//  JNDragDemo
//
//  Created by Jack on 2025/4/15.
//

import UIKit

class JNDragViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var rowData = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]
    var scrollTimer: Timer?
    let scrollZoneHeight: CGFloat = 60
    let scrollSpeed: CGFloat = 4
    
    lazy var mapView: UIView = {
        let view = UIView(frame: CGRectMake(0, 0, UIScreen.main.bounds.width, 350))
        view.backgroundColor = .lightGray
        return view
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel(frame: CGRectMake(0, self.mapView.frame.height * 0.5, UIScreen.main.bounds.width, 50))
        label.text = "假设这一块是地图\n(长按下面列表任意一行开始拖动)"
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    lazy var tableView: UITableView = {
        let frame = CGRectMake(0, self.mapView.frame.maxY, UIScreen.main.bounds.width, UIScreen.main.bounds.height - self.mapView.frame.maxY)
        let tableView = UITableView(frame: frame, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.layer.cornerRadius = 10
        tableView.register(JNDragTableViewCell.self, forCellReuseIdentifier: "JNDragTableViewCell")
        return tableView
    }()
    
    var snapshot: UIView?
    var sourceIndexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initUI()
    }
    
    func initUI() {
        self.view.backgroundColor = .clear
        self.view.addSubview(self.mapView)
        self.view.addSubview(self.titleLabel)
        self.view.addSubview(self.tableView)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture(_:)))
        self.tableView.addGestureRecognizer(longPress)
    }
    
    func maybeStartAutoScroll(at point: CGPoint) -> Bool {
        self.stopAutoScroll() // 取消上一个 timer
        
        let y = point.y
        let tableViewHeight = self.tableView.bounds.height
        
        var direction: CGFloat = 0
        
        if y < self.scrollZoneHeight + self.tableView.contentOffset.y {
            direction = -1
            print("向上滚")
        } else if y > tableViewHeight - self.scrollZoneHeight {
            direction = 1
            print("向下滚")
        } else {
            return false
        }
        
        self.scrollTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] _ in
            self?.autoScroll(direction: direction)
        }
        return true
    }
    
    func autoScroll(direction: CGFloat) {
        var offset = self.tableView.contentOffset
        offset.y += direction * self.scrollSpeed
        
        // 限制滚动边界
        offset.y = max(0, min(offset.y, self.tableView.contentSize.height - self.tableView.bounds.height))
        
        self.tableView.setContentOffset(offset, animated: false)
    }

    func stopAutoScroll() {
        self.scrollTimer?.invalidate()
        self.scrollTimer = nil
    }
    
    func changeRow(indexPath: IndexPath) {
        let item = self.rowData.remove(at: sourceIndexPath!.row)
        self.rowData.insert(item, at: indexPath.row)
        self.tableView.moveRow(at: self.sourceIndexPath!, to: indexPath)
        self.sourceIndexPath = indexPath
    }

    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.rowData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: JNDragTableViewCell = tableView.dequeueReusableCell(withIdentifier: "JNDragTableViewCell", for: indexPath) as! JNDragTableViewCell
        cell.updataData(title: "这是第 \(self.rowData[indexPath.row]) ")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    // MARK: - Gesture
    
    @objc func handleLongPressGesture(_ gesture: UILongPressGestureRecognizer) {
        let location = gesture.location(in: self.view)
        let tableViewLocation = gesture.location(in: self.tableView)
        guard let indexPath = self.tableView.indexPathForRow(at: tableViewLocation) else { return }

        switch gesture.state {
        case .began:
            self.sourceIndexPath = indexPath
            guard let cell = self.tableView.cellForRow(at: indexPath) else { return }
            self.snapshot = cell.snapshotView(afterScreenUpdates: true)
            self.snapshot?.frame.origin = cell.convert(CGPoint.zero, to: self.view)
            self.snapshot?.alpha = 0.8
            UIView.animate(withDuration: 0.25) {
                self.snapshot?.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            }
            self.snapshot?.layer.cornerRadius = 10
            self.snapshot?.clipsToBounds = true
            self.view.addSubview(self.snapshot!)
            cell.isHidden = true

        case .changed:
            NSObject.cancelPreviousPerformRequests(withTarget: self)
            let _ = self.maybeStartAutoScroll(at: tableViewLocation)
            self.snapshot?.center.y = location.y
            if indexPath != self.sourceIndexPath {
                self.changeRow(indexPath: indexPath)
            }
 
        case .ended:
            guard let cell = self.tableView.cellForRow(at: self.sourceIndexPath!) else { return }
            UIView.animate(withDuration: 0.25, animations: {
                self.snapshot?.frame.origin = cell.convert(CGPoint.zero, to: self.view)
                self.snapshot?.transform = .identity
                self.snapshot?.alpha = 0
            }, completion: { _ in
                cell.isHidden = false
                self.snapshot?.removeFromSuperview()
                self.snapshot = nil
            })
            self.sourceIndexPath = nil
            self.stopAutoScroll()
            print("拖动结束，更新地图")

        default:
            guard let cell = self.tableView.cellForRow(at: self.sourceIndexPath!) else { return }
            cell.isHidden = false
            self.snapshot?.removeFromSuperview()
            self.snapshot = nil
            self.sourceIndexPath = nil
            self.stopAutoScroll()
            print("拖动结束，更新地图")
        }
    }
}
