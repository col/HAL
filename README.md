![HAL 9000](http://upload.wikimedia.org/wikipedia/commons/thumb/f/f6/HAL9000.svg/440px-HAL9000.svg.png)

[![Build Status](https://travis-ci.org/col/HAL.svg)](https://travis-ci.org/col/HAL)

HAL
===

HAL is a hypermedia client library written in Swift that supports the [HAL+JSON hypermedia format](http://stateless.co/hal_specification.html).

## Features

- [x] Support for basic HAL+JSON documents
- [x] GET, POST, PUT, PATCH and DELETE
- [ ] Templated links
- [ ] Curries
- [ ] Authentication
- [ ] Improved error handling

## Requirements

- iOS 8.0+ / Mac OS X 10.9+
- Xcode 6.1

## Communication

- If you **found a bug**, open an issue.
- If you **have a feature request**, open an issue.
- If you **want to contribute**, submit a pull request.

## Installation

_Due to the current lack of [proper infrastructure](http://cocoapods.org) for Swift dependency management, using HAL in your project requires the following steps:_

1. Add HAL as a [submodule](http://git-scm.com/docs/git-submodule) by opening the Terminal, `cd`-ing into your top-level project directory, and entering the command `git submodule add https://github.com/col/HAL.git`
2. Open the `HAL` folder, and drag `HAL.xcodeproj` into the file navigator of your app project.
3. In Xcode, navigate to the target configuration window by clicking on the blue project icon, and selecting the application target under the "Targets" heading in the sidebar.
4. Ensure that the deployment target of HAL.framework matches that of the application target.
5. In the tab bar at the top of that window, open the "Build Phases" panel.
6. Expand the "Target Dependencies" group, and add `HAL.framework`.
7. Click on the `+` button at the top left of the panel and select "New Copy Files Phase". Rename this new phase to "Copy Frameworks", set the "Destination" to "Frameworks", and add `HAL.framework`.

---

## Usage

### Making a Request

```swift
import HAL

HAL.get("http://hal-sample-api.herokuapp.com").then(body:{ (client) in
	client.attribute("message")
})
```


### Creating a resource

```swift
import HAL

HAL.get("http://hal-sample-api.herokuapp.com").then(body:{ (client) in
	return client.post("items", ["title": "New Item", "description": "Sample item."])
}).then(body: { (newItem) -> Void in
	newItem.attribute("title")
})
```




