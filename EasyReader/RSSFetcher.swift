//
//  RSSFetcher.swift
//  EasyReader
//
//  Created by Oleg Gorelov on 09.05.17.
//  Copyright © 2017 Oleg Gorelov. All rights reserved.
//

import Foundation

class RSSFetcher: NSObject, XMLParserDelegate {
    
    private struct Element {
        
        static let item = "item"
        static let title = "title"
        static let description = "description"
        static let link = "link"
        static let pubDate = "pubDate"
        static let creator = "dc:creator"
        static let enclosure = "enclosure"
        static let rss = "rss"
        
    }
    
    private struct Values {
        
        static let jpegType = "image/jpeg"
        static let type = "type"
        static let url = "url"
        
    }
    
    private var intermediateItem: IntermediateItem?
    private var intermediateItems: [IntermediateItem]?
    private var foundString = ""
    
    func getRSSData(completionHandler:@escaping ([IntermediateItem]?) -> Void) {
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        
        if let url = UserDefaults.standard.url(forKey: Constant.rssStream) {
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            
            let task = session.dataTask(with: request) { (data, response, error) in
                ActivityIndicator.shared.decreaseActivity()
                if data != nil && error == nil {
                    let xmlParser = XMLParser(data: data!)
                    xmlParser.delegate = self
                    xmlParser.parse()
                    
                    completionHandler(self.intermediateItems)
                } else {
                    completionHandler(nil)
                }
                self.intermediateItems = nil
            }
            
            ActivityIndicator.shared.increaseActivity()
            task.resume()
        }

    }
    
    func getImage(fromUrl url: String) -> Data? {
        
        ActivityIndicator.shared.increaseActivity()
        if let imageURL = URL(string: url), let imageData = try? Data(contentsOf: imageURL) {
            ActivityIndicator.shared.decreaseActivity()
            return imageData
        }
        
        return nil
        
    }
    
    private func getLocalImageURL(fromRemoteImageURL imageURL: String) -> URL? {
        
        let localPath = imageURL.components(separatedBy: "/").last ?? ""
        
        let imagesFolderURL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(localPath)
        let imageLocalPath = imagesFolderURL?.absoluteString.appending(localPath)
        if imageLocalPath != nil {
            let imageLocalURL = URL(string: imageLocalPath!)
            return imageLocalURL
        }
        
        return nil
    }
   
    // MARK: - XMLParserDelegate
    
    func parserDidStartDocument(_ parser: XMLParser) {
        
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        //item = nil
        
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        
        switch elementName {
        case Element.title:
            intermediateItem?.title = foundString
        case Element.description:
            intermediateItem?.descrip = foundString
        case Element.link:
            intermediateItem?.link = foundString
        case Element.pubDate:
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "E, d MMM yyyy HH:mm:ss Z"
            dateFormatter.locale = Locale(identifier: "en_US")
            let date = dateFormatter.date(from: foundString)
            intermediateItem?.pubDate = date as NSDate?
        case Element.creator:
            intermediateItem?.creator = foundString
        case Element.item:
            if let item = intermediateItem {
                intermediateItems?.append(item)
            }
            intermediateItem = nil
        default:
            break
        }
        
        foundString = ""
    }
    
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        if elementName == Element.item {
            intermediateItem = IntermediateItem()
        } else if elementName == Element.enclosure && attributeDict[Values.type] == Values.jpegType {
            
            if let imageURL = attributeDict[Values.url], let imageData = getImage(fromUrl: imageURL) {
                
                intermediateItem?.imageURL = imageURL
                
                if let localImageURL = getLocalImageURL(fromRemoteImageURL: imageURL) {
                    
                    try? imageData.write(to: localImageURL, options: .atomic)
                    intermediateItem?.localImageURL = localImageURL.absoluteString
                }
                
            }
            
        } else if elementName == Element.rss {
            
            intermediateItems = [IntermediateItem]()
            
        }
        
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        foundString = string
    }
}
