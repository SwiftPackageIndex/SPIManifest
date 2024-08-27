# Handling Multiple Contributor Names with .mailmap

### Introduction

In some repositories, contributors may commit from different devices or with 
different configurations, leading to multiple names appearing for the same 
contributor. For example, a repository might show “John Doe” and “Johnathan 
Doe” as two separate contributors, even though they are the same person. 

This guide explains how to use a __.mailmap__ file to normalize commits and 
ensure a single contributor name appears in your Swift Package.

### Solution
A __.mailmap file__ allows contributors to map multiple email addresses and 
names to a single canonical name and email address. [Git](https://git-scm.com/docs/gitmailmap#:~:text=mailmap%20exists%20at%20the%20toplevel,real%20names%20and%20email%20addresses.) 
provides a description of what a __.mailmap__ file is and a good example 
can be found in [Swift-NIO](https://github.com/apple/swift-nio/blob/main/.mailmap).

#### Step-by-Step Guide
1. Create a .mailmap file in the root of your repository.
2. Add mappings in the .mailmap file to normalize the contributor names and 
email addresses. 
   - The format is: `Proper Name <canonical@example.com> <alias@example.com>`
      - example: `John Doe <john.doe@example.com> <johnathan.doe@example.com>`
      - this is an example of a __.mailmap__ file:
      ```
         John Doe <john.doe@example.com> <johnathan.doe@example.com>
         John Doe <john.doe@example.com> <johnd@example.com>
      ```
3. Add and commit the __.mailmap__ file:
 ```
 git add .mailmap
 git commit -m "Add .mailmap to normalize contributor names"
 git push origin main
 ```

4. Once the __.mailmap__ file is in place, the contributor list should reflect 
the normalized names. 

### Additional Configuration
If the .mailmap file does not completely resolve the issue, you can override the
 contributor list directly in the manifest. You can specify the contributors in 
 the manifest as follows:
 ```swift
 .metadata.authors([
    .author(name: "John Doe", email: "john.doe@example.com")
])
```
For more details refer to the [SPI Manifest Documentation](https://swiftpackageindex.com/swiftpackageindex/spimanifest/0.17.2/documentation/spimanifest/manifest/metadata-swift.struct/authors)