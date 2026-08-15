# MatchMate

MatchMate is a SwiftUI app that fetches profiles from the Random User API and lets the user Accept or Decline profiles.

I have also added local persistence so that the profiles and their Accept/Decline status are not lost when the app is closed. The app also supports cached images and showing previously loaded profiles when the device is offline.

## How to run

1. Clone the repository.
2. Open `MatchMate.xcodeproj` in Xcode.
3. Select the `MatchMate` scheme.
4. Run it on an iPhone simulator or a physical iPhone.
5. No API key is required because the app uses the Random User API.

To run the tests, use:

`⌘ + U`

The tests use mock networking and local data sources, so they don't depend on the actual API.

---

## Architecture

I used a simple MVVM + Repository approach.

The basic flow is:

```text
SwiftUI Views
     ↓
MatchesViewModel
     ↓
MatchesRepository
     ↓
 ┌───────────────┐
 │               │
Remote         Local
API            Core Data
```

### Views

The main UI is split into:

* `MatchesView` - shows the list of profiles.
* `ProfileCard` - shows each profile in the list.
* `ProfileDetailView` - shows the complete profile.
* `CachedAsyncImage` - handles loading and caching profile images.

The views don't directly talk to the API or Core Data. They send actions to the ViewModel.

### MatchesViewModel

`MatchesViewModel` manages the state needed by the UI.

It handles:

* Loading profiles
* Pagination
* Preventing duplicate profiles
* Accept
* Decline
* Loading state
* Error state

For example:

```text
User taps Accept
       ↓
MatchesViewModel.accept()
       ↓
Repository.updateStatus()
       ↓
LocalDataSource.updateStatus()
       ↓
Core Data
```

After the repository updates the status, the ViewModel also updates the profile in memory so SwiftUI immediately reflects the change.

---

## Why I used a Repository

I didn't want the ViewModel to know whether the data was coming from the API or Core Data.

The ViewModel only knows about:

```text
MatchesRepository
```

The repository handles the actual data source.

This makes it easier to:

* Add offline support
* Test the ViewModel/repository
* Replace the API later
* Keep networking and persistence code separate from the UI

---

## Database choice

I used **Core Data** for local persistence.

The main reason was that I needed the profile data and the Accept/Decline status to survive after the app is killed.

`ProfileEntity` stores the profile information along with:

```text
id
firstName
lastName
gender
email
phone
city
country
nationality
dateOfBirth
registeredDate
pictureLarge
pictureMedium
matchStatus
```

The profile ID is important because I use it to find an existing profile when new data comes from the API.

---

## How Accept / Decline status works

Accept and Decline are stored locally because the Random User API doesn't provide a real matchmaking backend.

For example, if a profile is Accepted:

```text
Profile
   ↓
Accept button
   ↓
MatchesViewModel
   ↓
Repository
   ↓
CoreDataLocalDataSource
   ↓
matchStatus = accepted
   ↓
context.save()
```

When the app starts again, Core Data returns the saved status.

One important part of the implementation is that when fresh API data comes in, I don't overwrite an existing local status.

For example:

```text
Before API refresh:

John → Accepted

API returns:

John → Pending
```

The local result stays:

```text
John → Accepted
```

The API is used to refresh the profile information, but the locally selected match status is preserved.

---

## Offline behaviour

The repository uses the API first and Core Data as the fallback.

```text
Fetch profiles
      ↓
Try API
   /     \
Success  Failure
  ↓        ↓
Save     Check Core Data
Core Data     ↓
  ↓       Cached profiles?
Return       /      \
profiles   Yes       No
            ↓         ↓
       Show cache    Show error
```

So if the user has already loaded profiles and then turns off mobile data/Wi-Fi, the app can still show the cached profiles.

If there is no cached data, then the app shows the network error.

---

## Image caching

Profile information and profile images are slightly different.

Core Data stores the profile information and image URLs, but an image URL by itself isn't enough to show an image without internet.

Because of this I added `CachedAsyncImage`.

The basic flow is:

```text
Image URL
   ↓
Check image cache
   ↓
 ┌───────┐
 │ Found │ → Show image
 └───────┘

If not found:
   ↓
Download image
   ↓
Store in cache
   ↓
Show image
```

This means previously loaded images can also be displayed while offline.

---

## Pagination

The API supports pages, so the ViewModel keeps track of the current page.

The flow is basically:

```text
Page 1 → load profiles
Page 2 → load more
Page 3 → load more
...
```

I also added duplicate checking using the profile ID.

Before adding a new page, I create a `Set` containing the IDs that are already displayed.

Then I only append profiles whose IDs aren't already present.

This was important because otherwise profiles could appear more than once when combining cached and newly fetched data.

I also use `isLoading` to prevent multiple fetch requests from happening at the same time.

---

## Testing

I added mocks for the remote service and local data source so that the repository can be tested without depending on the actual API.

Some of the things covered by the tests are:

* Successful API response
* API failure
* Returning cached profiles when the API fails
* Empty cache + API failure
* Saving profiles locally
* Preserving existing match status
* Updating Accept status
* Updating Decline status
* Repository calling the local data source correctly

The tests also helped catch an issue where the mock local data source wasn't actually containing the profile before an update was attempted.

---

## Project structure

The important files are roughly here:

```text
MatchMate
│
├── Data
│   ├── Local
│   │   ├── CoreDataLocalDataSource.swift
│   │   ├── LocalDataSource.swift
│   │   └── ProfileEntity+Mapping.swift
│   │
│   ├── Remote
│   │   └── RandomUserService.swift
│   │
│   └── Repositories
│       ├── MatchesRepository.swift
│       └── DefaultMatchesRepository.swift
│
├── Features
│   └── Matches
│       ├── Components
│       │   ├── CachedAsyncImage.swift
│       │   └── ProfileCard.swift
│       │
│       ├── ViewModels
│       │   └── MatchesViewModel.swift
│       │
│       └── Views
│           ├── MatchesView.swift
│           └── ProfileDetailView.swift
│
├── Persistence
│   ├── PersistenceController.swift
│   └── MatchMateModel.xcdatamodeld
│
└── MatchMateTests
    ├── Local
    ├── Networking
    ├── Repository
    └── Mocks
```

---

## Some trade-offs

I tried to keep the implementation simple rather than adding too many abstractions.

For example, pagination is currently handled by the ViewModel with a page number, loading flag and duplicate ID check. For a larger production app I would probably have a more complete pagination state, including something like `hasMorePages`.

The repository currently returns the persisted profiles after a successful API request. This makes the local match status the source of truth, which solved the status-reset issue, but it also means we fetch the local profiles again instead of just returning the newly downloaded page.

I used Core Data because the data is structured and I needed persistence. For this size of project, I didn't think adding another database layer would give much benefit.

Accept/Decline is local-only in this project because the API doesn't have an endpoint for actually saving a matchmaking decision. In a real application, this would need to go to a backend and Core Data would then act more like a local cache.

---

## Things I would improve for a production version

There are a few things I would improve if this was going beyond the take-home assignment:

* Add pull-to-refresh.
* Add a Retry button when the network fails.
* Have explicit `hasMorePages` pagination information.
* Add better image cache eviction/expiration.
* Add background synchronization.
* Sync Accept/Decline with a real backend.
* Add more detailed error handling instead of exposing raw networking errors.
* Potentially add a dedicated service for match actions if the backend supports them.

I intentionally didn't add these because they weren't necessary for the current requirements.

---

## Rough time spent

Around **8–10 hours** overall.

That included:

* Initial project setup
* API integration
* DTO/domain mapping
* Core Data
* Repository layer
* Offline fallback
* Image caching
* Pagination
* Accept/Decline handling
* Profile detail screen
* UI changes
* Unit tests
* Debugging and fixing persistence/pagination issues

---

## Overall flow

The main flow of the app is:

```text
                    ┌──────────────┐
                    │  Random User │
                    │     API      │
                    └──────┬───────┘
                           ↓
                    RandomUserService
                           ↓
                    MatchesRepository
                           ↓
                    Core Data / Cache
                           ↓
                    MatchesViewModel
                           ↓
                    ┌──────┴──────┐
                    ↓             ↓
              MatchesView   ProfileDetailView
                    ↓             ↓
                 User actions: Accept / Decline
                           ↓
                    Local status update
                           ↓
                       Core Data
```

The main goal was to keep each layer responsible for one thing: the views handle UI, the ViewModel handles UI state and user actions, the repository decides where data comes from, the remote service handles the API, and Core Data handles persistence.
