//
//  BoxView.swift
//  
//
//  Created by Vincent Young on 7/5/21.
//

import SwiftUI

#if os(iOS) || os(watchOS)

public struct BoxView: View {
    
    var style: ChartStyle
    var sections: [(sectionTitle: String, data: BoxChartData)]
    
    var title: String?
    var subtext: String?
    var boxesPerRow: Int
    @State var currentTouchedIndex: (Int, Int) = (-1,-1)
    
    /*
     Presentation constants. These must be defined so that DragGestures can identified and magnify boxes.
     - intraSectionSpacing: Spacing between each section's title text and its chart of boxes.
     - interSectionSpacing: VStack spacing between each section.
     - boxSpacing: Horizontal spacing between boxes in the same row.
     - rowSpacing: Vertical spacing between each row of boxes.
     */
    let mainVStackSpacing: CGFloat = 25
    let sectionTitleHeight: CGFloat = 20
    let interSectionSpacing: CGFloat = 20
    let intraSectionSpacing: CGFloat = 10
    let boxHeight: CGFloat = 12
    let boxSpacing: CGFloat = 8
    let rowSpacing: CGFloat = 10
    
    public init(style: ChartStyle, sections: [(String, BoxChartData)], title: String?, subtext: String?, boxesPerRow: Int) {
        self.style = style
        self.sections = sections
        self.title = title
        self.subtext = subtext
        self.boxesPerRow = boxesPerRow
    }
    
    @available(iOS 14.0, *)
    var vGridItems: [GridItem] {
        var gridItems: [GridItem] = []
        for _ in 0 ..< boxesPerRow {
            gridItems.append(GridItem())
        }
        return gridItems
    }
    
    /**
     Finds the indices of the section (in `sections`) and box (within the section's data) that a gesture location intersects with.
     `touchLocation`'s y-value must intersect with a section's LazyVGrid for a box to be identified for magnifying. The box closest to `touchLocation`'s x-value and y-values is then selected.
     If `touchLocation`'s y-value falls between sections, in a section's labels/spacing, or above/under the VStack of sections, no box is magnified.
     - parameter touchLocation: Location of the touch in the VStack of sections.
     - parameter totalWidth: The total width of the VStack of sections.
     - returns: Tuple containing the indicies of the section and box that touchLocation is closest to in the VStack fo sections
     */
    private func boxToMagnify(touchLocation: CGPoint, totalWidth: CGFloat) -> (Int, Int) {
        
        // y-value is above the VStack of sections. Return invalid indices.
        if touchLocation.y < 0 {
            return (-1,-1)
        }
        
        // Get row counts and heights of each section
        let sectionData: [(rows: Int, height: CGFloat)] = sections.map({
            let rowCount = ceil( Double($0.data.points.count)/Double(boxesPerRow) )
            return (rows: Int(rowCount),
                    height: (CGFloat(rowCount) * boxHeight) + (CGFloat(rowCount - 1) * rowSpacing))
        })
        
        // Search for which section touchLocation is in.
        var searchedHeight: CGFloat = 0
        let deadzoneHeight: CGFloat = sectionTitleHeight + intraSectionSpacing
        for sectionIdx in 0 ..< sectionData.count {
            if touchLocation.y < searchedHeight + deadzoneHeight + sectionData[sectionIdx].height {
                
                // If touchLocation's y-value falls in the dead zone (the section's title or the spacing between the section and the LazyVGrid), return invalid indices.
                if touchLocation.y < searchedHeight + deadzoneHeight {
                    return (-1, -1)
                } else {

                    // Iterate through the section's rows and find the row that `touchLocation` is vertically closest to.
                    var endOfCurrentRow: CGFloat = boxHeight + (rowSpacing/2)
                    var touchedRow: Int = 0
                    for rowIdx in 0 ..< sectionData[sectionIdx].rows {
                        if touchLocation.y - (searchedHeight + deadzoneHeight) > endOfCurrentRow {
                            endOfCurrentRow = endOfCurrentRow + boxHeight + rowSpacing
                        } else {
                            touchedRow = rowIdx; break
                        }
                    }
                    
                    // Find the box that's horizontally closest to `touchLocation`
                    let boxWidth = (totalWidth - (CGFloat(boxesPerRow - 1) * boxSpacing)) / CGFloat(boxesPerRow)
                    for boxIdx in 0 ..< boxesPerRow {
                        let totalWidth = (CGFloat(boxIdx + 1) * boxWidth)
                        let totalSpacing = (CGFloat(boxIdx) * boxSpacing) + (boxSpacing)/2
                        if touchLocation.x < totalWidth + totalSpacing {
                            return (sectionIdx, (touchedRow * boxesPerRow) + boxIdx)
                        }
                    }
                    return (sectionIdx, (touchedRow * boxesPerRow) + boxesPerRow - 1)
                    
                }
                
            } else {
                searchedHeight = searchedHeight + deadzoneHeight + sectionData[sectionIdx].height + interSectionSpacing
            }
        }
        
        // y-value is under VStack of sections. Return invalid indices.
        return (-1, -1)
        
    }
    
    public var body: some View {
        
        GeometryReader { gr in
            
            VStack(alignment: .leading, spacing: self.mainVStackSpacing) {
                
                if let titleString = self.title {
                    Text(titleString)
                        .bold()
                        .font(.title)
                        .foregroundColor(self.style.textColor)
                }
                
                if let subtextString = self.subtext {
                    Text(subtextString)
                        .font(.callout)
                        .foregroundColor(self.style.textColor)
                }
                
                // VStack of sections
                VStack(spacing: self.interSectionSpacing) {
                    
                    ForEach(0 ..< sections.count, id: \.self) { sectionIdx in
                        
                        // Section consisting of title and box chart
                        VStack(alignment: .leading, spacing: self.intraSectionSpacing) {
                            
                            Text(sections[sectionIdx].sectionTitle)
                                .bold()
                                .frame(height: self.sectionTitleHeight)
                            
                            if #available(iOS 14.0, *) {
                                
                                // onTapGesture is used before the gesture modifier w/DragGesture so that the DragGesture is delayed (https://www.hackingwithswift.com/forums/swiftui/a-guide-to-delaying-gestures-in-scrollview/6005)
                                LazyVGrid(columns: vGridItems, spacing: self.rowSpacing) {
                                    ForEach(0 ..< sections[sectionIdx].data.onlyPoints().count, id: \.self) { idx in
                                        Rectangle()
                                            .frame(height: self.boxHeight)
                                            .foregroundColor(sections[sectionIdx].data.getColor(
                                                                sections[sectionIdx].data.onlyPoints()[idx]))
                                            .onTapGesture {
                                                self.currentTouchedIndex = (sectionIdx, idx)
                                            }
                                            .scaleEffect(self.currentTouchedIndex == (sectionIdx, idx) ? 1.25 : 1)
                                            .animation(Animation.spring())
                                    }
                                }
                            }
                            
                        }
                        
                    }
                    
                }
                .gesture(
                    DragGesture()
                        .onChanged({ dragPoint in
                            self.currentTouchedIndex = self.boxToMagnify(touchLocation: dragPoint.location, totalWidth: gr.size.width)
                        }))
                
            }
            
        }
        
    }
    
}

#endif
