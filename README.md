# coding-challenge

In `UserClient.swift`

An env variable is expected

```
private var token: String {
     let env = ProcessInfo.processInfo.environment
     guard let index = env.index(forKey: "go_rest_token") else {
         return ""
     }
     return env[index].1
 }
