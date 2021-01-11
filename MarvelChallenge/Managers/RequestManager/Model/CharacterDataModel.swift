//
//  CharacterDataModel.swift
//  MarvelChallenge
//
//  Created by c80256a on 11/01/21.
//  Copyright © 2021 Henrique Silva. All rights reserved.
//

import UIKit

// MARK: - CharacterData
public struct CharacterData: Codable {
    public let code: Int?
    public let status: String?
    public let copyright: String?
    public let attributionText: String?
    public let attributionHTML: String?
    public let data: CharacterResult?
    public let etag: String?
    
    enum CodingKeys: String, CodingKey {
        case code
        case status
        case copyright
        case attributionText
        case attributionHTML
        case data
        case etag
    }
}

public struct CharacterResult: Codable {
    public let offset: Int?
    public let limit: Int?
    public let total: Int?
    public let count: Int?
    public let results: [Character]?
    
    enum CodingKeys: String, CodingKey {
        case offset = "offset"
        case limit = "limit"
        case total = "total"
        case count = "count"
        case results = "results"
    }
}

// MARK: - Result
public struct Character: Codable {
    public let id: Int?
    public let name: String?
    public let resultDescription: String?
    public let modified: String?
    public let thumbnail: Thumbnail?
    public let resourceUri: String?
    public let comics: Comics?
    public let series: Comics?
    public let stories: Stories?
    public let events: Comics?
    public let urls: [URLElement]?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case resultDescription = "description"
        case modified = "modified"
        case thumbnail = "thumbnail"
        case resourceUri = "resourceURI"
        case comics = "comics"
        case series = "series"
        case stories = "stories"
        case events = "events"
        case urls = "urls"
    }
}

// MARK: - Comics
public struct Comics: Codable {
    public let available: Int?
    public let collectionUri: String?
    public let items: [ComicsItem]?
    public let returned: Int?
    
    enum CodingKeys: String, CodingKey {
        case available = "available"
        case collectionUri = "collectionURI"
        case items = "items"
        case returned = "returned"
    }
}

// MARK: - ComicsItem
public struct ComicsItem: Codable {
    public let resourceUri: String?
    public let name: String?
    
    enum CodingKeys: String, CodingKey {
        case resourceUri = "resourceURI"
        case name = "name"
    }
}

// MARK: - Stories
public struct Stories: Codable {
    public let available: Int?
    public let collectionUri: String?
    public let items: [StoriesItem]?
    public let returned: Int?
    
    enum CodingKeys: String, CodingKey {
        case available = "available"
        case collectionUri = "collectionURI"
        case items = "items"
        case returned = "returned"
    }
}

// MARK: - StoriesItem
public struct StoriesItem: Codable {
    public let resourceUri: String?
    public let name: String?
    public let type: String?
    
    enum CodingKeys: String, CodingKey {
        case resourceUri = "resourceURI"
        case name = "name"
        case type = "type"
    }
}

// MARK: - Thumbnail
public struct Thumbnail: Codable {
    public let path: String?
    public let thumbnailExtension: String?
    
    enum CodingKeys: String, CodingKey {
        case path = "path"
        case thumbnailExtension = "extension"
    }
}

// MARK: - URLElement
public struct URLElement: Codable {
    public let type: String?
    public let url: String?
    
    enum CodingKeys: String, CodingKey {
        case type = "type"
        case url = "url"
    }
}
