////
////  MetadataSorter.swift
////  Clean Up App
////
////  Created by Aneesh Pandoh on 7/26/21.
////
//
//import Foundation
//
//import FirebaseStorage
//
//class metadataSorter: NSObject {
//
//
//
////import the metadata for every image
////get a list of all the metadata in the bucket or folder then create a for loop to loop through every file
//
////for x in list {
//    //let storageRef = .child(images/x)
//    //storageRef.getMetadata { metadata, error in
//    //if let error = error {
//      // Uh-oh, an error occurred!
//    //} else {
//      // Metadata now contains the metadata for
//    //}
//    //}
////}
//
//
//
//
////create array for latitude, longitude, and date
////metadatasorter.latitude , metadatasorter.longitude, metadatasorter.date
//
// //--Get the latitude from every single image
//
//
//var custom =  NSDictionary()
//var metadataunwrap = [NSDictionary]()
//private var metadatavar = [String: Any]()
//
//    func fetchMetadata() {
//        let storage = Storage.storage().reference()
//        let ref = storage.child("images/")
//        let group = DispatchGroup()
//        ref.listAll { (result, error) in
//            if let error = error {
//                print("Failed to ListALL")
//            }
//            result.items.forEach {item in
//                group.enter()
//                item.getMetadata { [self] metadata, error in
//                    if let error = error {
//                        print ("Failed to Retrieve Metadata")
//                        //Uh-oh, an error occurred!
//                    } else {
//                        metadatavar = (metadata?.dictionaryRepresentation())!
//                        //                    print(self.metadatavar)
//                        defer {
//                            group.leave()
//                        }
//                        metadataunwrap.append(metadatavar["metadata"] as! NSDictionary)
//
//                    }
//                }
//            }
//            group.notify(queue: .main, execute: {
//                print(self.createdata())
//            })
//        }
//    }
//    func createdata() -> (NSDictionary){
//        for i in self.metadataunwrap.indices {
//            self.custom = self.metadataunwrap[i]
//            print (self.custom["Latitude"] ?? "Cannot find Latitude")
//            print (self.custom["Date"] ?? "Cannot find Date")
//            print (self.custom["Longitude"] ?? "Cannot find Longitude")
//        }
//        return self.custom
//    }
//}
//
////        var longitude = longitudeImport.map { Double($0)! }
////        var latitude = latitudeImport.map { Double($0)! }
////    }
////}
//
