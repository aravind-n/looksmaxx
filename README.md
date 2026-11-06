<picture>
  <source media="(prefers-reduced-motion: reduce)" srcset="assets/readme-header.png">
  <img src="assets/readme-header.gif" alt="Looksmaxx. I like this. More like that. This part is cool. Make it mine.">
</picture>

# looksmaxx

Give your agent a few sites you like, a screenshot, or a rough idea. Looksmaxx turns that into a design language in `DESIGN.md`, then builds from it.

## Install

macOS / Linux (On Windows use Git Bash or WSL):

```sh
curl -fsSL https://raw.githubusercontent.com/aravind-n/looksmaxx/main/install.sh | sh
```

## Examples

### Shop

[![Shop: a record player lifts on hover, its finish changes through real controls, and scrolling reveals more products.](assets/examples/shop.gif)](assets/examples/shop.gif)

_**Playful · Tactile · Bold**: Put the objects on stage, and make browsing feel hands-on._

### Product

[![Product: tabs switch between a topology diagram and waveform, then scrolling reveals more of the interface.](assets/examples/product.gif)](assets/examples/product.gif)

_**Precise · Instrumented · Layered**: Make a complex system legible through visible structure and state._

### Kinetic Swiss

[![Kinetic Swiss: variable type swells near the cursor, marquees move in opposing directions, and a colored tile changes shape on hover.](assets/examples/kinetic-swiss.gif)](assets/examples/kinetic-swiss.gif)

_**Confidence · Reactive**: Typography is the interface: large, bold, and responsive to your cursor._

### Editorial

[![Editorial: a hover responds, then scrolling reveals large serif type, generous space, fine rules, and architectural photography.](assets/examples/editorial.gif)](assets/examples/editorial.gif)

_**Editorial · Spacious · Framed**: Give the images room, and let typography guide the reading._

## Usage

Invoke the skill in your agent:

```text
/looksmaxx build my portfolio.
I like these sites: [links].
Help me figure out what I like about them, then build with that direction.
```

Steer it in plain language: “too busy,” “more like the first one,” “this part is cool.” For the language alone, ask for `DESIGN.md` without a build.
