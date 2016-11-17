## Overview
```
This project is a chrome extension example for site okky.kr 
built with  purescript compiler + webpack build tool
```

## How to start
```
git clone <this repo>
cd <cloned directory> 
npm install
npm run debug or npm run release
```

## Development Build
```
npm run debug
```

## Release Build
```
npm run release
```

## Output Directory
```
./debug 
./release
```

## Repl
```
pulp psci
```

## Auto watching and building  
```javascript
content    script : npm run watch-content
background script : npm run watch-background

// open browser localhost:8080/options.html and you'll
// see the options page.
options    script : npm run watch-options
```

## Install purescript dependency package
```
bower install purescript-jquery <optional param>

eg) bower install purescript-jquery --save
    this command installs  jquery package and write down
    dependency on bower.json
```

## Search and Info bower package
```
bower [search | info] <package name>#<optional version>

eg) bower info purescript-jquery#^3.0.0
```

##  Individual Compiling Command
```

pulp build -m <Main Moduel Name>  -t <Destination>release/content.js

eg) pulp build -m Main -t release/content.js
    pulp build -m Back -t release/background.js
    pulp build -m Opt -t release/options.js
```