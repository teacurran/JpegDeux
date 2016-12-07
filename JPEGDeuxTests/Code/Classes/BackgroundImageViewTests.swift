//
//  BackgroundImageViewTests.swift
//  JPEGDeux
//
//  Created by Terrence Curran on 12/6/16.
//
//

import Foundation
import XCTest

class BackgroundImageViewTests: XCTestCase {
    
    let screenSize: NSRect = NSRect(x: 0, y:0, width:1024, height: 768);
    
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testShouldBeAbleToScaleToFit() {
        
        let backgroundImageView: BackgroundImageView = BackgroundImageView(frame: screenSize)
        backgroundImageView.setImageScaling(ScaleToFit)
        
        let sizeScaled = backgroundImageView.scaledSize(for: NSSize(width: 600, height: 200))
        XCTAssertEqual(screenSize.height, sizeScaled.height)
        XCTAssertEqual(screenSize.width, sizeScaled.width)

        let sizeScaled2 = backgroundImageView.scaledSize(for: NSSize(width: 220, height: 423))
        XCTAssertEqual(screenSize.height, sizeScaled2.height)
        XCTAssertEqual(screenSize.width, sizeScaled2.width)
   
    }
}
