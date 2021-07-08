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
    @State var currentTouchedIndex: (Int, Int) = (0,0)
    
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
        
        VStack(alignment: .leading, spacing: 25) {
            
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
            
            ForEach(0 ..< sections.count, id: \.self) { sectionIdx in
                
                VStack(alignment: .leading, spacing: 5) {
                    
                    Text(sections[sectionIdx].sectionTitle)
                        .bold()
                    
                    if #available(iOS 14.0, *) {
                        LazyVGrid(columns: vGridItems) {
                            ForEach(0 ..< sections[sectionIdx].data.onlyPoints().count, id: \.self) { idx in
                                Rectangle()
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
        
    }
    
}

#endif
