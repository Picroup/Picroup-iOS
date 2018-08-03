//
//  Client.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/11.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Apollo

// apollo-codegen download-schema https://home.picroup.com:3500/graphql --output schema.json

extension ApolloClient {
    
    static let shared: ApolloClient = {
        let client = ApolloClient(url: URL(string: "\(Config.baseURL)/graphql")!)
        client.cacheKeyForObject = { $0["id"] }
        return client
    }()
}


/* Generate GraphQL Apollo API:
 
 APOLLO_FRAMEWORK_PATH="$(eval find $FRAMEWORK_SEARCH_PATHS -name "Apollo.framework" -maxdepth 1)"
 
 if [ -z "$APOLLO_FRAMEWORK_PATH" ]; then
 echo "error: Couldn't find Apollo.framework in FRAMEWORK_SEARCH_PATHS; make sure to add the framework to your project."
 exit 1
 fi
 
 cd "${SRCROOT}/${TARGET_NAME}"
 $APOLLO_FRAMEWORK_PATH/check-and-run-apollo-codegen.sh generate $(find . -name '*.graphql') --schema UseCases/GraphQL/schema.json --output UseCases/GraphQL/API.swift
 
**/
