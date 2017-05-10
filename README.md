# elm-giphy-displayer

## Features

* Based on http://elm-lang.org/examples/http
* Uses `localStorage` to persist the topic and the current gif

## Usage

To try it out run:

```shell
$ elm make src/app.elm --output app.js
```

Then you can open `index.html` in your browser.

### Notes

`elm-reactor` does not work because `index.html` has to embed the elm app in JS for access to the `localStorage` API through Elm Ports.
