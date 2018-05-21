//
//  FeedItemEntity.swift
//  sight
//
//  Created by Kensuke Kousaka on 2018/05/13.
//  Copyright © 2018 k3n.link. All rights reserved.
//

import Foundation
import FeedKit

class FeedItemEntities {
  var contentsList: [FeedItemEntity] = []

  func parse(data: Data) {
    guard let parser: FeedParser = FeedParser(data: data) else {
      print("Failure initializing FeedParser")
      return
    }
    let parsed = parser.parse()
    switch parsed {
    case .atom(_):
      guard let atomFeed = parsed.atomFeed, parsed.isSuccess else {
        print("Atom feed parse error: \(String(describing: parsed.error))")
        return
      }
      guard let entries = atomFeed.entries else {
        print("Atom feed entries is nil")
        return
      }

      for entry in entries {
        var authors: [String] = []
        for author in entry.authors ?? [] {
          authors.append(author.name ?? "")
        }
        var categories: [String] = []
        for category in entry.categories ?? [] {
          categories.append(category.attributes?.label ?? "")
        }

        self.contentsList.append(FeedItemEntity(
          channel: FeedItemChannelEntity(title: atomFeed.title ?? "", link: atomFeed.links?.first?.attributes?.href ?? "", description: atomFeed.subtitle?.value ?? "", lastUpdated: atomFeed.updated),
          article: FeedItemArticleEntity(title: entry.title ?? "", link: entry.links?.first?.attributes?.href ?? "", description: entry.summary?.value ?? "", authors: authors, publishedDate: entry.published, categories: categories)
        ))
      }
    case .rss(_):
      guard let rssFeed = parsed.rssFeed, parsed.isSuccess else {
        print("RSS feed parse error: \(String(describing: parsed.error))")
        return
      }
      guard let items = rssFeed.items else {
        print("RSS feed items is nil")
        return
      }

      for item in items {
        var categories: [String] = []
        for category in item.categories ?? [] {
          categories.append(category.attributes?.domain ?? "")
        }


        self.contentsList.append(FeedItemEntity(
          channel: FeedItemChannelEntity(title: rssFeed.title ?? "", link: rssFeed.link ?? "", description: rssFeed.description ?? "", lastUpdated: rssFeed.lastBuildDate),
          article: FeedItemArticleEntity(title: item.title ?? "", link: item.link ?? "", description: item.description ?? "", authors: [item.author ?? ""], publishedDate: item.pubDate, categories: categories)))
      }
    case .json(_):
      guard let jsonFeed = parsed.jsonFeed, parsed.isSuccess else {
        print("JSON feed parse error: \(String(describing: parsed.error))")
        return
      }
      guard let items = jsonFeed.items else {
        print("JSON feed items is nil")
        return
      }

      for item in items {
        self.contentsList.append(FeedItemEntity(
          channel: FeedItemChannelEntity(title: jsonFeed.title ?? "", link: jsonFeed.homePageURL ?? "", description: jsonFeed.description ?? "", lastUpdated: nil),
          article: FeedItemArticleEntity(title: item.title ?? "", link: item.url ?? "", description: item.summary ?? "", authors: [item.author?.name ?? ""], publishedDate: item.datePublished, categories: item.tags ?? [])))
      }
    case let .failure(error):
      print("Parse failure: \(String(describing: error))")
      return
    }
  }
}

struct FeedItemEntity {
  var channel: FeedItemChannelEntity?
  var article: FeedItemArticleEntity?
}

/// Channel (Site) Information
struct FeedItemChannelEntity {
  var title: String = ""
  var link: String = ""
  var description: String = ""
  var lastUpdated: Date?
}

/// Article Information
struct FeedItemArticleEntity {
  var title: String = ""
  var link: String = ""
  var description: String = ""
  var authors: [String] = []
  var publishedDate: Date?
  var categories: [String] = []
}
