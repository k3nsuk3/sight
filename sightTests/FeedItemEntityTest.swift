//
//  FeedItemEntityTest.swift
//  sightTests
//
//  Created by Kensuke Kousaka on 2018/05/13.
//  Copyright © 2018 k3n.link. All rights reserved.
//

import Quick
import Nimble
import FeedKit
@testable import sight

class FeedItemEntityTest: QuickSpec {
  override func spec() {
    let testBundle = Bundle(for: type(of: self))
    describe("parse rss 1.0 xml as FeedItemEntity") {
      context("contains only channel info") {
        it("contains only channel info") {
          let path = testBundle.url(forResource: "Rss1ContainsNoArticle", withExtension: "xml")
          guard let xmlData: Data = try? Data(contentsOf: path!, options: .uncached) else {
            fail("Failed to load resource")
            return
          }

          let entity = FeedItemEntity()
          entity.parse(data: xmlData)
          expect(entity.article).to(beNil())
          expect(entity.channel).toNot(beNil())

          guard let parser: FeedParser = FeedParser(data: xmlData) else {
            fail("Failed to initialize FeedParser")
            return
          }

          let result = parser.parse()
          expect(result.isSuccess).to(beTrue())

          guard let feed = result.rssFeed else {
            fail("Failed to get rssFeed")
            return
          }

          guard let title = feed.title else {
            return
          }

          print(title)
        }
      }
    }
  }
}
