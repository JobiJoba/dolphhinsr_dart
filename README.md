# W.I.P
This is currently not functional ! If you are interested in the project feel free to submit an improvement or else;


# DolphinSR_Dart

This projet is a copy of the DolphinSR algorithm from Yodaiken which was written in Javascript.
I need something like that in DART ... so I'm translating it. [Link to original library](https://github.com/yodaiken/dolphinsr) 

(Following is from the original module)

DolphinSR implements [spaced repetition](https://en.wikipedia.org/wiki/Spaced_repetition) in
JavaScript. Specifically, it uses [Anki's modifications](https://apps.ankiweb.net/docs/manual.html#what-algorithm)
to the SM2 algorithm including:

- an initial mode for learning new cards
- a mode for re-learning cards after forgetting them
- reducing the number of self-assigned ratings from 6 to 4
- factoring lateness into card scheduling
- Anki's default configuration options

While DolphinSR is intentionally very similar to Anki's algorithm, it does deviate in a few ways:

- improved support for adding reviews out of order (for example, due to network latency)
- very different internal data structures (DolphinSR is largely written in a functional style to
  make testing and debugging easier, and does not rely on storing computed data or any SQL database)
- only one kind of card


## Installation
Soon


## Quick Start

Soon


## API

Soon
