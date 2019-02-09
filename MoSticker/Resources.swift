//
//  Resources.swift
//  MoSticker
//
//  Created by Moses Mok on 25/1/2019.
//  Copyright © 2019 Moses Mok. All rights reserved.
//

import UIKit

/// Resources for the app.
class R {
    /// Common resources across different classes.
    class Common {
        static var userDateFormatter: DateFormatter {
            get {
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium
                dateFormatter.timeStyle = .none
                return dateFormatter
            }
        }
        
        static let cancel = "Cancel"
        static let done = "Done"
        static let edit = "Edit"
        static let ok = "OK"
        
        static let noNameMessage = "<No name>"
        static let noDateMessage = "<No date>"
        static let noOwnerNameMessage = "<No owner name>"
        static let ownedMessage = " [Yourself]"

        static let removePackConfirmMessage = "Are you sure to remove this sticker pack? You cannot undo this action."
        static let removePackAction = "Remove Pack"
        static let removingMessage = "Removing..."
        static let removePackErrorTitle = "Error: Failed when Removing Pack"
        static let removePackErrorMessage = "An error has occurred when removing sticker pack."
        
        static let uploadingMessage = "Uploading..."
        static let uploadPackErrorTitle = "Error: Failed to Upload Pack"
        static let uploadPackErrorMessage = "An error has occurred when uploading packs."
        
        static let publisherSuffix = " @ MoSticker"
        static let publisherLocal = "MoSticker"
    }
    
    /// Resources used by AppDelegate.
    class AD {
        static let injectionPath = "/Applications/InjectionIII.app/Contents/Resources/iOSInjection10.bundle"
    }
    
    /// Resources used by HomeVC.
    class HoVC {
        static let packCellID = "packCell"
        static let addToEditPackSegueID = "mainAdd-editPack"
        static let cellToEditPackSegueID = "mainCell-editPack"
    }
    /// Resources used by ProfileVC.
    class ProVC {
        static let selectionSegueID = "profile-selection"
        static let editPackSegueID = "profile-editPack"
        static let textFieldCellID = "textFieldCell"
        static let packCellID = "packCell"
        
        static let displayNameProperty = "Display Name"
        static let displayNameFooter = "The display name is public to any user."
        
        static let displayNameEmptyTitle = "Empty Display Name"
        static let displayNameEmptyMessage = "The display name must not be empty."
        
        static let retrievePackErrorTitle = "Error: Failed to Retrieve Packs"
        static let retrievePackErrorMessage = "An error has occurred when retrieving sticker packs from database."
        
        static let updatePackErrorTitle = "Error: Failed to Update Pack"
        static let updatePackErrorMessage = "An error has occurred when updating the list of sticker packs."
        
        static let changeNameErrorTitle = "Error: Failed to Update Name"
        static let changeNameErrorMessage = "An error has occurred when updating the display name."
        
        static let updatingNameMessage = "Updating Display Name..."
    }
    /// Resources used by LocalSelectionVC.
    class LSVC {
        static let emptyTitle = "No Existing Packs"
        static let emptyMessage = "You have not created any sticker packs in the 'Packs' tab."
    }
    /// Resources used by SearchVC.
    class SearVC {
        static let packCellID = "packCell"
        static let toEditPackSegueID = "search-editPack"
        
        static let barPlaceholder = "Search Packs"
        static let noResults = "No Results\n\nMake sure all words are spelled correctly, and try different keywords."
        static let nothingMoreFooter = "Nothing More"
        static let limitReachedFooter = "Number of Results Reached Limit\n\nTry to search more specifically."
    }
    /// Resources used by SettingVC.
    class SetVC {
        static let disclosureCellID = "disclosureCell"
        
        static let logInSignUp = "Log In / Sign Up"
        static let logOut = "Log Out"
        
        static let signOutErrorTitle = "Error: Failed to Sign Out"
        static let signOutErrorMessage = "An error has occurred when signing out."
    }
    
    /// Resources used by EditPackLocalVC and EditPackDBVC.
    class EPVCs {
        static let viewStickerAction = "View Sticker"
        
        static let removeStickerConfirmMessage = "Are you sure to remove this sticker? You cannot undo this action."
        static let removeStickerAction = "Remove Sticker"
        
        static let unknownError = "Unknown Error"
        static let sendWhatsAppErrorMessage = "Failed to send sticker pack to WhatsApp."
        
        static let nameProperty = "Name"
        static let idProperty = "Identifier"
        static let publishProperty = "Publisher"
        static let ownerProperty = "Owner"
        static let iconProperty = "Pack Icon"
        static let changeIcon = "Change Icon"
        static let addSticker = "Add Sticker"
        static let sendWhatsApp = "Send to WhatsApp"

        static let nameIDFooter = "The name must be less than 128 characters."
        static let stickerEditFooter = "Tap on a sticker to view or remove it from the pack. Each pack must have a minimum of 1 stickers and a maximum of 30 stickers."
        static let stickerNonEditFooter = "Tap on a sticker to view it."
        static let iconFooter = "Choose an image to represent the sticker pack."
        
        static let trayIconRes = 96
        static let stickerRes = 512
        
        class Local {
            static let propertyCellID = "propertyCell"
            static let buttonCellID = "buttonCell"
            static let imageSelectionCellID = "imageSelectCell"
            static let galleryCellID = "galleryCell"
            static let toPECropSegueID = "editPackLocal-peCrop"
            static let toPECropScrollSegueID = "editPackLocal-peCropScroll"
            static let toViewImgSegueID = "editPackLocal-viewImg"
        }
        class DB {
            static let propertyCellID = "propertyCell"
            static let buttonCellID = "buttonCell"
            static let imageSelectionCellID = "imageSelectCell"
            static let galleryCellID = "galleryCell"
            static let toPECropSegueID = "editPackDB-peCrop"
            static let toPECropScrollSegueID = "editPackDB-peCropScroll"
            static let toViewImgSegueID = "editPackDB-viewImg"
        }
    }
    
    /// Resources used by Photo Editing (PE) classes.
    class PE {
        static let cachedImgRes = 96

        class CroVC {
            static let toBackRemoveSegueID = "PECrop-PEBackRemove"
            static let minImageScale: CGFloat = 0.6
            
            static let selectSourceMessage = "Select image source"
            static let fromCameraMessage = "From Camera"
            static let fromLibraryMessage = "From Photo Library"
        }
        class CroSVC {
            static let toBackRemoveSegueID = "PECropScroll-PEBackRemove"

            static let selectSourceMessage = "Select image source"
            static let fromCameraMessage = "From Camera"
            static let fromLibraryMessage = "From Photo Library"
            
            static let cropErrorTitle = "Error: Failed to Crop Image"
            static let cropErrorMessage = "An error has occurred when cropping image."
        }
        class BRVC {
            static let toTagSegueID = "peBackRemove-tag"
            
            static let enableScrollIcon = UIImage(named: "move_arrows_enabled")
            static let disableScrollIcon = UIImage(named: "move_arrows_disabled")
            static let enableIncludeIcon = UIImage(named: "pencil_enabled")
            static let disableIncludeIcon = UIImage(named: "pencil_disabled")
            static let enableExcludeIcon = UIImage(named: "eraser_enabled")
            static let disableExcludeIcon = UIImage(named: "eraser_disabled")
            
            static let processingMessage = "Processing Sticker..."
            static let processErrorTitle = "Error: Failed to Process Sticker"
            static let processErrorMessage = "An error has occurred when processing sticker."
        }
        class TagVC {
            static let disableScrollIcon = UIImage(named: "move_arrows_disabled")
            static let enableScrollIcon = UIImage(named: "move_arrows_enabled")
            static let disableBrushIcon = UIImage(named: "brush_disabled")
            static let enableBrushIcon = UIImage(named: "brush_enabled")
            static let disableEraserIcon = UIImage(named: "eraser_disabled")
            static let enableEraserIcon = UIImage(named: "eraser_enabled")
            static let disableTextIcon = UIImage(named: "text_insert_disabled")
            static let enableTextIcon = UIImage(named: "text_insert_enabled")
            
            static let toToolOptSegueID = "PETagging-PEToolOpt"
            static let toColorPickerSegueID = "peTagVC-colorPicker"
        }
    }
    
    /// Resources used by table view and collection view cells.
    class Cells {
        class SPackTVC {
            static let imageCellID = "imageCell"
        }
        class GalTVC {
            static let imageCellID = "imageCell"
        }
    }
    
    /// Resources used by Helper.
    class Helper {
        static let emptyLabelText = "Press the + button to create a new sticker pack."
        static let noAuthLabelText = "You are not signed in. Please go to the 'Settings' tab, and tap '\(R.SetVC.logInSignUp)' to sign in."
    }
}
