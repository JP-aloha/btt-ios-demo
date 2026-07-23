# Example-SwiftUI

A SwiftUI app for interacting with a custom ecommerce API.

## Getting Started

Create `DeveloperConfig.xcconfig` with the following contents at the repo's root directory to override the base URL for the API, the Blue Triangle site ID, and the project development team: 

```
BASE_URL = <Your URL (excluding `https://`)>
SITE_ID = <Your Site ID>
DEVELOPMENT_TEAM = <Your Team ID>
CLARITY_PROJECT_ID = <Your Clarity Project ID>
```

**NOTE**: you must create this file and provide at least a `BASE_URL` as the default value is not operational.


