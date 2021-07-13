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
     Presentation constants. These must be defined so that the boxes that DragGestures intersect with can be identified
     - intraSectionSpacing: Spacing between each section's title text and its chart of boxes.
     - interSectionSpacing: VStack spacing between each section
     - rowSpacing: Spacing between each row of boxes
     */
    let mainVStackSpacing: CGFloat = 25
    let sectionTitleHeight: CGFloat = 20
    let interSectionSpacing: CGFloat = 20
    let intraSectionSpacing: CGFloat = 10
    let boxHeight: CGFloat = 12
    let rowSpacing: CGFloat = 8
    
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
                
                VStack(spacing: self.interSectionSpacing) {
                    
                    ForEach(0 ..< sections.count, id: \.self) { sectionIdx in
                        
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
                                            .gesture(
                                                DragGesture()
                                                    .onChanged({ value in
                                                        self.currentTouchedIndex = (sectionIdx, idx)
                                                    }))
                                            .scaleEffect(self.currentTouchedIndex == (sectionIdx, idx) ? 1.25 : 1)
                                            .animation(Animation.spring())
                                    }
                                }
                            }
                            
                        }
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
}

#endif
