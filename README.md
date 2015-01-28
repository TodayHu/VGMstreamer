# VGMstreamer
## AppleWatch feature still in beta of Xcode 6.2, unstable

## Project Description
#### 中文
**Video Game Music streamer** 是 "khinsider VGM" 遊戲音樂網站的**非官方**移動端程式，使用 Swift 在 iOS 8 上實作。

因為該網站未提供 json/xml 做索引，所以只好對網站內容物使用 parser 硬幹，
第一次讀取專輯內容的時候需要時間，但讀取完畢後會存入資料庫，下次就不需要再讀取了。

專輯列表右上方的按鈕可以將專輯加入我的最愛專輯，我的最愛專輯可從 app 首頁右上方的按鈕進入。在最愛專輯列表上左滑可以將此專輯移出我的最愛專輯。

歌曲列表右的愛心按鈕可以講歌曲加入我的最愛歌曲，我的最愛歌曲可從 app 首頁的下方的按鈕進入。重複點擊愛心按鈕可以將此首歌移出我的最愛歌曲。

裡頭沒有任何一首歌的版權是屬於我的，而且 khinsider 隨時都有可能改變網站的結構。
因此應該視這個案子為參考用的練習，而非成品。


#### English
**Video Game Music streamer** is an **non-official** front-end app which written with Swift at iOS 8 for "khinsider VGM" video game music site.

This site doesn't provide json/xml information so I have to parse full content.
It will take a while for first time to fetch song lists and save into CoreData.

The right-top button on the album list will add this album into *My Favorite Albums*.
*My Favorite Albums* is accessible from the right-top button on app's first page.
Slide-left to remove an album from *My Favorite Albums*.

The right heart button on the song list will add this song into *My Favorite Songs*.
*My Favorite Songs* is accessible from the second button on app's first page.
Tap again the heart button to remove a song from *My Favorite Songs*.

I don't own any copyright of these songs and khinsider might change the website structure anytime.
Therefore, this project should take as a practice but not a product.

## Example
![Main.storyboard](https://github.com/tsunghao/VGMstreamer/blob/master/screenshots/01_storyboard.png)
![Main Page](https://github.com/tsunghao/VGMstreamer/blob/master/screenshots/02_MainPage.png)
![Album Loading Page](https://github.com/tsunghao/VGMstreamer/blob/master/screenshots/03_fetchingAlbumList.png)
![Add Album into Favorite List](https://github.com/tsunghao/VGMstreamer/blob/master/screenshots/04_addFavoriteAlbum.png)
![Song List Page](https://github.com/tsunghao/VGMstreamer/blob/master/screenshots/05_addFavoriteSongs.png)
![Pull to Refresh](https://github.com/tsunghao/VGMstreamer/blob/master/screenshots/06_pulltoRefresh.png)
![My Favorite Albums](https://github.com/tsunghao/VGMstreamer/blob/master/screenshots/07_favoriteAlbumList.png)
![My Favorite Songs](https://github.com/tsunghao/VGMstreamer/blob/master/screenshots/08_favoriteSongList.png)
![Apple Watch](https://github.com/tsunghao/VGMstreamer/blob/AppleWatch/screenshots/09_AppleWatch.png)


## File Description
| Filename | Purpose |
|---|---|
| LetterViewController.swift | Main page view controller |
| AlbumListTableViewController.swift | Album List view controller |
| FavoriteAlbumTableViewController.swift | Favorite album view controller |
| SongListTableViewController.swift | Song list view controller |
| SongTableViewCell.swift | Song list table cell controller |
| StringHandle.swift | Class for handling strings |
| WebContent.swift | Class for fetching web page |
| AlertMessage.swift | Class for showing alert message |
| Main.storyboard | UI layout |
| Info.plist | meta information for app |


## VGM Website

Google `khinsider Game mp3`
