# elm-giphy-displayer

![elm-version](https://img.shields.io/badge/Elm-0.18.0-green.svg)

## Screenshot

![](https://github.com/Gira-X/elm-giphy-displayer/raw/master/screenshots/1.png)

## Features

* Based on http://elm-lang.org/examples/http from https://guide.elm-lang.org/architecture/effects/http.html
* Uses `localStorage` to persist the topic and the current gif

Check the live demo at https://gira-x.github.io/elm-giphy-displayer/index.html

## Usage

To compile:

```shell
$ elm make src/Main.elm --output app.js
```

Then you can open `index.html` in your browser.

### Notes

* `elm-reactor` does not work because `index.html` has to embed the elm app in JS for access to the `localStorage` API through Elm Ports.
* The compiled `app.js` is included in the repo to allow the Github Page demo to work
