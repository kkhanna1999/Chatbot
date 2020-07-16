class BotSuggestions {
  List<String> suggestions = [];
// Gets List of options Bot is proving to user
// used for creating buttons
  BotSuggestions(List<dynamic> messages) {
    messages.forEach((message) {
      if (message['payload'] != null) {
        List<dynamic> suggestionList = message['payload']['suggestions'];
        suggestionList.forEach((suggestion) => suggestions.add(suggestion));
      }
    });
  }
}

//List of images/gfs
// can be modified to handle videos.
class BotImages {
  List<String> images = [];

  BotImages(List<dynamic> uri) {
    uri.forEach((image) {
      if (image['payload'] != null) {
        List<dynamic> imageList = image['payload']['images'];
        imageList.forEach((suggestion) => images.add(suggestion));
      }
    });
  }
}

//List of some addional information to be displayed after image or gifs.
class BotInfo {
  List<String> info = [];

  BotInfo(List<dynamic> information) {
    information.forEach((msg) {
      if (msg['payload'] != null) {
        List<dynamic> infoList = msg['payload']['more'];
        infoList.forEach((suggestion) => info.add(suggestion));
      }
    });
  }
}

// handeling links
class BotLink {
  List<String> links = [];

  BotLink(List<dynamic> link) {
    link.forEach((url) {
      if (url['payload'] != null) {
        List<dynamic> linkList = url['payload']['link'];
        linkList.forEach((suggestion) => links.add(suggestion));
      }
    });
  }
}
