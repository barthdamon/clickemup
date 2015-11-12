//
//  ViewController.swift
//  TriangleClicker
//
//  Created by Matthew Barth on 11/11/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  @IBOutlet weak var timeLabel: UILabel!
  @IBOutlet weak var scoreLabel: UILabel!
  @IBOutlet weak var gameView: UIView!
  @IBOutlet weak var startButton: UIButton!
  
  @IBOutlet weak var objectView: UIView!
  @IBOutlet weak var practiceView: UIView!
  
  //typealiases
  enum CCs: Double {
    case Up = 225.0
    case Down = 45.0
    case Right = 315.0
    case Left = 135.0
  }
  enum SelectedSet: String {
    case Up = "Up"
    case Down = "Down"
    case Right = "Right"
    case Left = "Left"
  }
  typealias Coordinates = (x: CGFloat, y: CGFloat)
  typealias CoordinateArray = Array<Coordinates>
  let standardWidth: CGFloat = 50
  let standardHeight: CGFloat = 50
  
  //Hardcoded Data Sets
  let rightFacingSet: [(x: CGFloat, y: CGFloat)] = [(x: 200 , y: 200), (x: 150, y: 150), (x: 100, y: 100), (x: 150, y: 250), (x: 100, y: 300)]
  let upFacingSet: [(x: CGFloat, y: CGFloat)] = [(x: 200 , y: 100), (x: 150, y: 150), (x: 100, y: 200), (x: 250, y: 150), (x: 300, y: 200)]
  let leftFacingSet: [(x: CGFloat, y: CGFloat)] = [(x: 100 , y: 200), (x: 150, y: 150), (x: 200, y: 100), (x: 150, y: 250), (x: 200, y: 300)]
  let downFacingSet: [(x: CGFloat, y: CGFloat)] = [(x: 200 , y: 300), (x: 150, y: 250), (x: 100, y: 200), (x: 250, y: 250), (x: 300, y: 200)]
  
  //LiveData
  var sets: Array<CoordinateArray>?
  var triangleViews: [UIView] = []
  var selectedSet: SelectedSet?
  var turnedView: UIView?
  
  //Administrative
  var score = 0
  var time = 15
  var timer: NSTimer?
  var gameOver = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    sets = [rightFacingSet, upFacingSet, leftFacingSet, downFacingSet]
  }
  
  func selectRandomSet() {
    removeAllTriangles()
    if !gameOver {
      let rand = Int(arc4random_uniform(4))
      if let sets = self.sets {
        let randomSet: Array<Coordinates> = sets[rand]
        setSelectedSet(rand)
        drawTriangles(randomSet)
      }
    } else {
      self.timeLabel.text = "GAME OVER"
      self.startButton.hidden = false
    }
  }
  
  func setSelectedSet(rand: Int) {
    switch rand {
    case 0:
      self.selectedSet = .Right
    case 1:
      self.selectedSet = .Up
    case 2:
      self.selectedSet = .Left
    case 3:
      self.selectedSet = .Down
    default:
      break
    }
    if let selected = self.selectedSet?.rawValue {
      print("SET SELECTED: \(selected)")
    }
  }
  
  func triangleTapped(triangle: UITapGestureRecognizer) {
    print("Triangle Selected: \(triangle)")
    if let selected = triangle.view {
      if selected == turnedView {
        score++
        selected.backgroundColor = UIColor.greenColor()
      } else {
        selected.backgroundColor = UIColor.redColor()
        score--
      }
      scoreLabel.text = String(score)
      transitionToNewTriangles()
    }
  }
  
  @IBAction func startButtonPressed(sender: AnyObject) {
    self.gameOver = false
    selectRandomSet()
    self.startButton.hidden = true
    self.time = 15
    timer = NSTimer()
    timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "tickTock", userInfo: nil, repeats: true)
  }
  
  func transitionToNewTriangles() {
    UIView.animateWithDuration(0.1, animations: { () -> Void in
      self.objectView.alpha = 0
      }, completion: { (complete) -> Void in
        self.selectRandomSet()
        UIView.animateWithDuration(0.1, animations: { () -> Void in
          self.objectView.alpha = 1
        })
    })
  }
  
  func tickTock() {
    time--
    self.timeLabel.text = String(time)
    if time == 0 {
      timer?.invalidate()
      gameOver = true
    }
  }
  
  
  
  //MARK: DRAWING
  func removeAllTriangles() {
    for triangle in self.triangleViews {
      triangle.removeFromSuperview()
    }
    self.turnedView = nil
    self.triangleViews.removeAll()
  }
  
  func drawTriangles(set: Array<Coordinates>) {
    //1: draw the frames
    for triangleCoords in set {
      self.triangleViews.append(generateView(triangleCoords))
    }
    //2: turn into triangles
    for view in triangleViews {
      applyTriangleLayer(view)
    }
    //3: rotate
    rotateTriangles()
    //code
  }
  
  func rotateTriangles() {
    let rand = Int(arc4random_uniform(5))
    turnedView = triangleViews[rand]
    
    var degrees: CCs?
    var offsetDegrees: CCs?
    
    if let set = self.selectedSet {
      switch set {
      case .Up:
        degrees = CCs.Up
        offsetDegrees = CCs.Down
        break
      case .Down:
        degrees = CCs.Down
        offsetDegrees = CCs.Up
        break
      case .Left:
        degrees = CCs.Left
        offsetDegrees = CCs.Right
        break
      case .Right:
        degrees = CCs.Right
        offsetDegrees = CCs.Left
        break
      }
    }
    if let turned = turnedView, offset = offsetDegrees?.rawValue, degrees = degrees?.rawValue {
      for view in triangleViews {
        if view == turned {
          let transformation: CGFloat = CGFloat(offset * M_PI / 180.0)
          view.transform = CGAffineTransformMakeRotation(transformation)
        } else {
          let transformation: CGFloat = CGFloat(degrees * M_PI / 180.0)
          view.transform = CGAffineTransformMakeRotation(transformation)
        }
      }
    }
  }
  
  func generateView(coords: Coordinates) -> UIView {
    let view = UIView(frame: CGRectMake(coords.x, coords.y, 50, 50))
    view.backgroundColor = UIColor.blackColor()
    let tapRecognizer = UITapGestureRecognizer(target: self, action: "triangleTapped:")
    tapRecognizer.numberOfTapsRequired = 1
    tapRecognizer.numberOfTouchesRequired = 1
    view.addGestureRecognizer(tapRecognizer)
    objectView.addSubview(view)
    return view
  }
  
  func applyTriangleLayer(view: UIView) {
    let layerHeight = view.layer.frame.height
    let layerWidth = view.layer.frame.width
    
    // Create Path
    let bezierPath = UIBezierPath()
    
    // Draw Points
    bezierPath.moveToPoint(CGPointMake(0, layerHeight))
    bezierPath.addLineToPoint(CGPointMake(layerWidth, layerHeight))
    bezierPath.addLineToPoint(CGPointMake(layerHeight, 0))
    bezierPath.addLineToPoint(CGPointMake(0, layerHeight))
    bezierPath.closePath()
    
    // Apply Color
    let shapeLayer = CAShapeLayer()
    shapeLayer.path = bezierPath.CGPath
    view.layer.mask = shapeLayer
  }
  
  func createFrame(x: CGFloat, _ y: CGFloat) {
    let frame = CGRectMake(x, y, standardWidth, standardHeight)
    let viewToAdd = UIView(frame: frame)
    viewToAdd.backgroundColor = .yellowColor()
    gameView.addSubview(viewToAdd)
  }
  
}

