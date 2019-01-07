//
//  VoteViewController.swift
//  petpageant2
//
//  Created by Michael Sweeney on 1/4/19.
//  Copyright © 2019 Novasoft. All rights reserved.
//

import UIKit

class VoteViewController: UIViewController {

    //MARK: OUTLETS
    
    @IBOutlet weak var topVoteView: VotePicView!
    @IBOutlet weak var bottomVoteView: VotePicView!
    
    let recordManager = RecordManager()
    
    //MARK: VIEWCONTROLLER METHODS
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setDelegates()
        self.setupPanGestures()
        self.offsetVoteViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.offsetVoteViews()
        self.enterShowDownState()
    }
    
    fileprivate func setDelegates() {
        self.topVoteView.delegate = self
        self.bottomVoteView.delegate = self
    }
    
    fileprivate func offsetVoteViews() {
        DispatchQueue.main.async {
            self.topVoteView.center.x = self.view.frame.width * 2
            self.bottomVoteView.center.x = self.view.frame.width * -2
        }
    }
    
    func resupplyRecordQueue() {
        if self.recordManager.records.count < 12 {
            self.recordManager.fetchRecordBatch { (success) in
                self.attachRecordsToVoteViews()
                if self.topVoteView.center.x != self.bottomVoteView.center.x {
                    self.animateViewsIn()
                }
                self.displayImagesForVoteViews()
            }
        } else {
            self.attachRecordsToVoteViews()
            self.displayImagesForVoteViews()
        }
    }
    
    //ButtonVoting protocol
    internal func didVoteViaButton(forView: VoteView) {
        
        var otherivew = VoteView()
        
        if(topVoteView == forView){
            otherivew = bottomVoteView
        } else if (bottomVoteView == forView) {
            otherivew = topVoteView
        }
        self.updatePetRecordsOnVoteCast(forView, nonselectedView: otherivew)
        self.animateViewsOut(forView, otherView: otherivew)
    }
    
    internal func didPassViaButton(forView: VoteView) {
        var otherivew = VoteView()
        
        if(topVoteView == forView){
            otherivew = bottomVoteView
        } else if (bottomVoteView == forView) {
            otherivew = topVoteView
        }
        
        self.animateViewsOut(forView, otherView: otherivew)
    }
    
    func enterShowDownState() {
        self.animateViewsIn()
        self.resupplyRecordQueue()
    }
    
    //MARK: CLASS METHODS
    
    func displayImagesForVoteViews() {
        self.displayImageIn(voteView: self.topVoteView)
        self.displayImageIn(voteView: self.bottomVoteView)
    }
    
    func displayImageIn(voteView: VoteView) {
        voteView.fetchImageForRecord { (success) in
            if success == true {
                print("did fetch image for pet")
                voteView.enterVotingState()
            } else {
                print("no img yet! - Time to retry!")
                self.displayImageIn(voteView: voteView)
            }
        }
    }
    
    fileprivate func attachRecordsToVoteViews() {
        guard let result = self.recordManager.getTwoRecords() else {
            print("Could not get two records")
            return
        }
        
        self.topVoteView.petRecord = result.0
        self.bottomVoteView.petRecord = result.1
    }
    
    fileprivate func updatePetRecordsOnVoteCast(_ selectedView: UIView, nonselectedView: UIView) {
        if selectedView == self.topVoteView {
            self.topVoteView.incrementRecordsVotes()
            self.bottomVoteView.incrementRecordsViews()
        } else {
            self.topVoteView.incrementRecordsViews()
            self.bottomVoteView.incrementRecordsVotes()
        }
    }
    
    //To handle collision for dual-view pan
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.topVoteView.isUserInteractionEnabled = false
        self.bottomVoteView.isUserInteractionEnabled = false
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.topVoteView.isUserInteractionEnabled = true
        self.bottomVoteView.isUserInteractionEnabled = true
    }
    
    //MARK: ANIMATIONS
    fileprivate func animateViewsIn() {
        self.topVoteView.animateViewIn()
        self.bottomVoteView.animateViewIn()
    }
    
    fileprivate func animateViewsOut(_ selectedView: UIView, otherView: UIView){
        
        // casted vote by swiping to the right
        if selectedView.center.x > self.view.center.x || selectedView.center.x == self.view.center.x {
            
            UIView.animate(withDuration: gVoteAnimationOutTime, animations: {
                
                selectedView.center.x = self.view.frame.width * 2
                otherView.center.x = self.view.frame.width * -2
                
            }, completion: { (true) in
                
                self.enterShowDownState()
            })
            
        }
            
            // casted vote by swiping to the left
        else if selectedView.center.x < self.view.center.x {
            
            UIView.animate(withDuration: gVoteAnimationOutTime, animations: {
                
                selectedView.center.x = self.view.frame.width * -2
                otherView.center.x = self.view.frame.width * 2
                
            }, completion: { (true) in
                
                self.enterShowDownState()
            })
        }
    }
    
    //MARK: PAN GESTURE
    
    fileprivate func setupPanGestures(){
        let topPanGesture = UIPanGestureRecognizer(target: self, action: #selector(self.viewWasPanned(_:)))
        let bottomPanGesture = UIPanGestureRecognizer(target: self, action: #selector(self.viewWasPanned(_:)))
        self.topVoteView.addGestureRecognizer(topPanGesture)
        self.bottomVoteView.addGestureRecognizer(bottomPanGesture)
    }
    
    public func viewWasPanned(_ sender: UIPanGestureRecognizer) {
        print("detected pan")
        guard let view = sender.view else {return}
        let originalCenter = self.view.center.x
        let translation = sender.translation(in: view)
        var selectedView = VoteView()
        var otherView = VoteView()
        
        if view == topVoteView {
            selectedView = topVoteView
            otherView = bottomVoteView
        }
            
        else if view == bottomVoteView {
            selectedView = bottomVoteView
            otherView = topVoteView
        }
        
        switch sender.state {
        case .began:
            otherView.disableInteraction()
        case .changed:
            selectedView.center.x = originalCenter + translation.x
            let alphaSet = (abs(translation.x) / 180) // percentage view movement where 100% is equal to 180 pts.
            otherView.alterAlphaForUnselectedState(alpha: max(0.3, 1 - alphaSet))
            
            //hit our threshold
            //                if (1 - alphaSet) <= 0.4 {
            //
        //            }
        case .ended:
            
            if otherView.alpha < 0.4 {
                view.isUserInteractionEnabled = false
                otherView.isUserInteractionEnabled = false
                self.updatePetRecordsOnVoteCast(selectedView, nonselectedView: otherView)
                self.animateViewsOut(view, otherView: otherView)
            } else {
                selectedView.center.x = originalCenter
                selectedView.alterAlphaForUnselectedState(alpha: 1.0)
                otherView.alterAlphaForUnselectedState(alpha: 1.0)
                selectedView.isUserInteractionEnabled = true
                otherView.isUserInteractionEnabled = true
            }
            
        default:
            print("no action triggered")
            return
        }
    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
